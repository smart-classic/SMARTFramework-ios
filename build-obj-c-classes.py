#
#	Creates Objective-C classes from our ontology.
#

### config ###
_overwrite = True
_obj_c_class_prefix = 'SM'
_generated_classes_dir = 'SMARTFramework/GeneratedClasses'
_smart_ontology_uri = 'https://raw.github.com/chb/smart_common/adding-0.5-models/schema/smart.owl'

### there's probably no need to edit anything beyond this line ###
### ---------------------------------------------------------- ###

_classes_to_ignore = [
	'AnyURI',
	'AppManifest',
	'Call',
	'Cell',
	'Component',
	'ContainerManifest',
	'Filter',
	'Home',
	'Literal',
	'Ontology',
	'Parameter',
	'ParameterSet',
	'Pref',
	'SMARTAPI',
	'UserPreferences',
	'VCardLabel',
	'Work',
]

_property_template = """/// Representing {{ uri }}
@property (nonatomic, {{ strength }}) {{ useClass }} *{{ name }};"""

_literal_getter_template = """- ({{ itemClass }} *){{ name }}
{
	if (!_{{ name }}) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"{{ uri }}"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		RedlandStatement *rslt = [query nextObject];
		self.{{ name }} = [rslt.object literalValue];
	}
	return _{{ name }};
}"""

_multi_literal_getter_template = """- (NSArray *){{ name }}
{
	if (!_{{ name }}) {
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"{{ uri }}"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		// loop results
		NSMutableArray *arr = [NSMutableArray array];
		RedlandStatement *rslt = nil;
		while ((rslt = [query nextObject])) {
			{{ itemClass }} *newItem = [rslt.object literalValue];		// only works for NSString for now
			if (newItem) {
				[arr addObject:newItem];
			}
		}
		self.{{ name }} = arr;
	}
	return _{{ name }};
}"""

_model_getter_template = """- ({{ itemClass }} *){{ name }}
{
	if (!_{{ name }}) {
		
		// get the "{{ name }}" element
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"{{ uri }}"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create a model containing the statements
		RedlandModel *newModel = [[RedlandModel alloc] initWithStorage:self.model.storage];
		RedlandStatement *newStmt = [RedlandStatement statementWithSubject:rslt.object predicate:nil object:nil];
		RedlandStreamEnumerator *newStream = [self.model enumeratorOfStatementsLike:newStmt];
		
		// add statements to the new model
		@try {
			for (RedlandStatement *stmt in newStream) {
				[newModel addStatement:stmt];
			}
		}
		@catch (NSException *e) {
			DLog(@"xx>  %@ -- %@", [e reason], [e userInfo]);
			[self.model print];
		}
		
		self.{{ name }} = [{{ itemClass }} newWithModel:newModel];
	}
	return _{{ name }};
}"""

_multi_model_getter_template = """- (NSArray *){{ name }}
{
	if (!_{{ name }}) {
		
		// get the "{{ name }}" elements
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"{{ uri }}"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:nil predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		// loop through the results
		NSMutableArray *arr = [NSMutableArray array];
		RedlandStatement *rslt = nil;
		while ((rslt = [query nextObject])) {
			
			// create a model containing the statements
			RedlandModel *newModel = [[RedlandModel alloc] initWithStorage:self.model.storage];
			RedlandStatement *newStmt = [RedlandStatement statementWithSubject:rslt.object predicate:nil object:nil];
			RedlandStreamEnumerator *newStream = [self.model enumeratorOfStatementsLike:newStmt];
			
			// add statements to the new model
			@try {
				for (RedlandStatement *stmt in newStream) {
					[newModel addStatement:stmt];
				}
			}
			@catch (NSException *e) {
				DLog(@"xx>  %@ -- %@", [e reason], [e userInfo]);
				[self.model print];
			}
			
			{{ itemClass }} *newItem = [{{ itemClass }} newWithModel:newModel];
			if (newItem) {
				[arr addObject:newItem];
			}
		}
		self.{{ name }} = arr;
	}
	return _{{ name }};
}"""


### ---------------------------------------------------------- ###


import os
import re
import urllib2
import datetime
from smart_client_python.common import rdf_ontology


def toObjCClassName(name):
	"""Converts any name into a hopefully acceptable Objective-C class name,
	prepending the prefix defined in "_obj_c_class_prefix".
	"""
	
	basename = None
	if name and len(name) > 1:
		parts = re.split(r'[-_\W]', name)
		basename = ''.join(['%s%s' % (p[0].upper(), p[1:]) for p in parts])
	elif name:
		basename = name.upper()
	
	if basename:
		return '%s%s' % (_obj_c_class_prefix, basename)
	return None;


def toObjCPropertyName(name):
	"""Converts any property name into a hopefully acceptable Objective-C
	property name.
	"""
	
	if name and len(name) > 1:
		parts = re.split(r'[-_\W]', name)
		cap = ''.join(['%s%s' % (p[0].upper(), p[1:]) for p in parts])
		return '%s%s' % (cap[0].lower(), cap[1:])
	return name.lower() if name else None


def handle_class(a_class, known_classes, ontology_file_name='smart.owl'):
	"""Returns a dictionary with substitutions to fill the class template files.
	
	Feed it a SMART_Class that it should create an Objective-C class for, this
	class then fills a dictionary with the values for template keys. The
	dictionary can then be used to substitute placeholders in the class
	template files:
	- CLASS_NAME
	- CLASS_SUPERCLASS
	- CLASS_FORWARDS
	- CLASS_PROPERTIES
	- CLASS_GETTERS
	- RDF_TYPE
	- ONTOLOGY_PATH
	- AUTHOR
	- DATE
	- YEAR
	"""
	
	# do we already have this class?
	if a_class.name in known_classes:
		print 'xx>  %s is already known, skipping' % a_class.name
		return None
	
	# start the dictionary
	d = datetime.date.today()
	myDict = {
		'CLASS_NAME': toObjCClassName(a_class.name),
		'CLASS_SUPERCLASS': 'SMDocument' if True else 'SMObject',	# TODO: Figure out which to use
		'RDF_TYPE': unicode(a_class.uri),
		'ONTOLOGY_PATH': ontology_file_name,
		'AUTHOR': __file__,
		'DATE': str(d),
		'YEAR': str(d.year),
	}
	
	# get properties that represent other classes (OWL_ObjectProperty instances)
	c_forwards = set()
	prop_statements = []
	prop_getter = []
	for o_prop in a_class.object_properties:
		# o_prop.multiple_cardinality   ->  Bool whether the property can have multiple items
		# o_prop.to_class			    ->  SMART_Class represented by the property
		# o_prop.to_class.uri   	  	->  Class URI
		itemClass = toObjCClassName(o_prop.to_class.name)
		c_forwards.add(itemClass)
		prop = {
			'name': toObjCPropertyName(o_prop.name),
			'uri': o_prop.uri,
			'itemClass': itemClass,
			'useClass': 'NSArray' if o_prop.multiple_cardinality else itemClass,
			'strength': 'copy' if o_prop.multiple_cardinality else 'strong',
		}
		
		stmt = apply_template(_property_template, prop)
		prop_statements.append(stmt)
		
		getter_template = _multi_model_getter_template if o_prop.multiple_cardinality else _model_getter_template
		getter = apply_template(getter_template, prop)
		prop_getter.append(getter)
	
	# get data properties (OWL_DataProperty instances)
	for d_prop in a_class.data_properties:
		primitive = 'NSString'			# TODO: When to use NSNumber or NSDate?
		prop = {
			'name': toObjCPropertyName(d_prop.name),
			'uri': d_prop.uri,
			'itemClass': primitive,
			'useClass': 'NSArray' if d_prop.multiple_cardinality else primitive,
			'strength': 'copy',
		}
		
		stmt = apply_template(_property_template, prop)
		prop_statements.append(stmt)
		
		getter_template = _multi_literal_getter_template if d_prop.multiple_cardinality else _literal_getter_template
		getter = apply_template(getter_template, prop)
		prop_getter.append(getter)
	
	# apply to dict
	myDict['CLASS_FORWARDS'] = '@class %s;' % ', '.join(c_forwards) if len(c_forwards) > 0 else ''
	myDict['CLASS_PROPERTIES'] = "\n\n".join(prop_statements)
	myDict['CLASS_GETTERS'] = "\n\n".join(prop_getter)
	
	# add it to the known classes dict
	known_classes[a_class.name] = myDict
	return myDict


def download(url, directory=None, filename=None, force=False, nostatus=False):
	"""Downloads a URL to a file with the same name, unless overridden
	
	Returns the path to the file downloaded
	
	Will NOT download the file if it exists at target directory and filename,
	unless force is True
	"""
	
	# can we write te the directory?
	if directory is None:
		abspath = os.path.abspath(__file__)
		directory = os.path.dirname(abspath)

	if not os.access(directory, os.W_OK):
		raise Exception("Can't write to %s" % directory)
	
	if filename is None:
		filename = os.path.basename(url)
	
	# if it already exists, we're not going to do anything
	path = os.path.join(directory, filename)
	if os.path.exists(path):
		if force:
			os.remove(path)
		else:
			print "-->  %s has already been downloaded" % filename
			return path
	
	# create url and file handles
	urlhandle = urllib2.urlopen(url)
	filehandle = open(path, 'wb')
	meta = urlhandle.info()
	
	# start
	filesize = int(meta.getheaders("Content-Length")[0])
	print "-->  Downloading %s (%s KB)" % (filename, filesize / 1000)
	
	loaded = 0
	blocksize = 8192
	while True:
		buffer = urlhandle.read(blocksize)
		if not buffer:
			break
		
		loaded += len(buffer)
		filehandle.write(buffer)
		
		if not nostatus:
			status = r"%10d	 [%3.2f%%]" % (loaded, loaded * 100.0 / filesize)
			status = status + chr(8) * (len(status) + 1)
			print status,
	
	if not nostatus:
		print
	
	# return filename
	filehandle.close()
	return path


def apply_template(template, subst):
	"""Substitutes all values of the "subst" dictionary in the template with its
	values
	"""
	
	applied = template
	for k, v in subst.iteritems():
		applied = re.sub('\{\{\s*' + k + '\s*\}\}', v, applied)
	
	return applied


if __name__ == "__main__":
	"""Outputs Objective-C classes to be used in our iOS framework
	"""
	
	# the ontology file is not included in the python client, so we download it
	owl = download(_smart_ontology_uri, '.', 'smart.owl', False, True)
	if owl is None:
		print 'xx>  Error downloading %s' % _smart_ontology_uri
		os.exit(1)
	
	# grab the template files
	template_h_path = 'SMARTFramework/ClassTemplate.h'
	if not os.path.exists(template_h_path):
		print 'xx>  The .h template could not be found at %s' % template_h_path
		os.exit(1)
	template_m_path = 'SMARTFramework/ClassTemplate.m'
	if not os.path.exists(template_m_path):
		print 'xx>  The .m template could not be found at %s' % template_m_path
		os.exit(1)
	
	template_h = open(template_h_path).read()
	template_m = open(template_m_path).read()
	
	# parse the ontology
	print '-->  Parsing ontology'
	f = open(owl).read()
	rdf_ontology.parse_ontology(f)
	
	# prepare to grab classes
	if not os.path.exists(_generated_classes_dir):
		os.mkdir(_generated_classes_dir)
	if not os.access(_generated_classes_dir, os.W_OK):
		raise Exception("Can't write to %s" % _generated_classes_dir)
	
	print '-->  Processing classes'
	known_classes = {}			# will be name: URIRef
	num_generated = 0
	
	# loop all SMART_Class instances
	for o_class in rdf_ontology.api_types:
		if o_class.name in _classes_to_ignore:
			continue
		
		d = handle_class(o_class, known_classes)
		if d:
			filename_h = '%s.h' % d['CLASS_NAME']
			path_h = os.path.join(_generated_classes_dir, filename_h)
			if not _overwrite and os.path.exists(path_h):
				print 'xx>  Class %s already exists at %s, skipping' % (d['CLASS_NAME'], path_h)
				continue
			
			filename_m = '%s.m' % d['CLASS_NAME']
			path_m = os.path.join(_generated_classes_dir, filename_m)
			if not _overwrite and os.path.exists(path_m):
				print 'xx>  Implementatino for %s already exists at %s, skipping' % (d['CLASS_NAME'], path_m)
				continue
			
			# finish the header
			header = apply_template(template_h, d)
			handle = open(path_h, 'w')
			handle.write(header)
			
			# finish the implementation
			implem = apply_template(template_m, d)
			handle = open(path_m, 'w')
			handle.write(implem)
			
			num_generated += 1
	
	# all done
	print '-->  Done. %d classes written.' % num_generated

