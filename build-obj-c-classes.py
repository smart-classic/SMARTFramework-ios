#
#	Creates Objective-C classes from our ontology.
#
#	Pass in the "-f" flag if you want to overwrite existing classes
#

### config ###
_obj_c_class_prefix = 'SM'
_template_dir = 'Generator'
_generated_classes_dir = 'SMARTFramework/GeneratedClasses'
_smart_ontology_uri = 'https://raw.github.com/chb/smart_common/dev/schema/smart.owl'

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
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
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
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
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
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		RedlandStatement *rslt = [query nextObject];
		
		// create an item for this object
		self.{{ name }} = [{{ itemClass }} newWithSubject:rslt.object inModel:self.model];
	}
	return _{{ name }};
}"""

_multi_model_getter_template = """- (NSArray *){{ name }}
{
	if (!_{{ name }}) {
		
		// get the "{{ name }}" elements
		RedlandNode *predicate = [RedlandNode nodeWithURIString:@"{{ uri }}"];
		RedlandStatement *statement = [RedlandStatement statementWithSubject:self.subject predicate:predicate object:nil];
		RedlandStreamEnumerator *query = [self.model enumeratorOfStatementsLike:statement];
		
		// loop through the results
		NSMutableArray *arr = [NSMutableArray array];
		RedlandStatement *rslt = nil;
		while ((rslt = [query nextObject])) {
			
			// instantiate an item for each object
			{{ itemClass }} *newItem = [{{ itemClass }} newWithSubject:rslt.object inModel:self.model];
			if (newItem) {
				[arr addObject:newItem];
			}
		}
		self.{{ name }} = arr;
	}
	return _{{ name }};
}"""

_class_base_path_getter_template = """+ (NSString *)basePath
{
	return @"{{ base_path }}";
}"""

_record_multi_item_getter_template = """/**
 *  {{ description }}.
 *  Makes a call to {{ path }}, originally named "{{ orig_name }}".
 *  @param callback A INSuccessRetvalueBlock block that will have a success flag and a user info dictionary containing the desired objects (key: INResponseArrayKey) if successful.
 */
{{ method_signature }}
{
	NSString *path = [NSString stringWithFormat:@"{{ nsstring_path }}", self.record_id];
	[self getObjectsOfClass:[{{ item_class }} class] from:path callback:callback];
}"""




### ---------------------------------------------------------- ###


import os
import sys
import re
import urllib2
import datetime
from smart_client_python.common import rdf_ontology

_arguments = sys.argv[1:] if len(sys.argv) > 1 else []
_overwrite = '-f' in _arguments

_record_calls = []
_single_item_calls = []


def toObjCClassName(name):
	"""Converts any name into a hopefully acceptable Objective-C class name,
	prepending the prefix defined in "_obj_c_class_prefix".
	"""
	
	basename = None
	if name and len(name) > 1:
		parts = re.split(r'[-_\W]', name)
		real_parts = []
		for p in parts:
			if p and len(p) > 1:
				real_parts.append(p)
		
		basename = ''.join(['%s%s' % (p[0].upper(), p[1:]) for p in real_parts])
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
		real_parts = []
		for p in parts:
			if p and len(p) > 1:
				real_parts.append(p)
		
		cap = ''.join(['%s%s' % (p[0].upper(), p[1:]) for p in real_parts])
		return '%s%s' % (cap[0].lower(), cap[1:])
	return name.lower() if name else None


def handle_class(a_class, ontology_file_name='smart.owl'):
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
	- BASE_PATH
	- RDF_TYPE
	- ONTOLOGY_PATH
	- AUTHOR
	- DATE
	- YEAR
	"""
	
	# start the dictionary
	now = datetime.date.today()
	base_path = o_class.base_path
	class_name = toObjCClassName(a_class.name)
	myDict = {
		'CLASS_NAME': class_name,
		'CLASS_SUPERCLASS': 'SMDocument' if base_path else 'SMObject',
		'BASE_PATH': None,
		'RDF_TYPE': unicode(a_class.uri),
		'ONTOLOGY_PATH': ontology_file_name,
		'AUTHOR': __file__,
		'DATE': str(now),
		'YEAR': str(now.year),
	}
	
	c_forwards = set()
	prop_statements = []
	prop_getter = []
	
	# get properties that represent other classes (OWL_ObjectProperty instances)
	my_properties = []
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
			'_template': _multi_model_getter_template if o_prop.multiple_cardinality else _model_getter_template
		}
		
		my_properties.append(prop)
	
	# get data properties (OWL_DataProperty instances)
	for d_prop in a_class.data_properties:
		primitive = 'NSString'			# TODO: When to use NSNumber or NSDate?
		prop = {
			'name': toObjCPropertyName(d_prop.name),
			'uri': d_prop.uri,
			'itemClass': primitive,
			'useClass': 'NSArray' if d_prop.multiple_cardinality else primitive,
			'strength': 'copy',
			'_template': _multi_literal_getter_template if d_prop.multiple_cardinality else _literal_getter_template
		}
		my_properties.append(prop)
	
	# sort and apply property dicts to the templates
	my_properties = sorted(my_properties, key=lambda k: k['name'])
	for prop in my_properties:
		stmt = apply_template(_property_template, prop)
		prop_statements.append(stmt)
		
		getter = apply_template(prop['_template'], prop)
		prop_getter.append(getter)
	
	# base path
	if base_path:
		# we need to convert "allergy_id", "medication_id" and the like to "uuid"
		base_path = re.sub(r'(\{record_id\}/\w+/\{\s*)[a-z]+_id(\})', '\g<1>uuid\g<2>', base_path)
		t_base = apply_template(_class_base_path_getter_template, {'base_path': base_path})
		myDict['BASE_PATH'] = t_base
	
	# add properties to our dict
	myDict['CLASS_FORWARDS'] = '@class %s;' % ', '.join(sorted(c_forwards)) if len(c_forwards) > 0 else ''
	myDict['CLASS_PROPERTIES'] = "\n\n".join(prop_statements)
	myDict['CLASS_GETTERS'] = "\n\n".join(prop_getter)
	
	# calls for this class (SMART_API_Call instances)
	global _record_calls
	prefix = '- (void)'
	block_arg = '(INSuccessRetvalueBlock)callback'
	if a_class.calls and len(a_class.calls) > 0:
		for api in a_class.calls:
			
			# we can only use record-scoped calls
			if 'record' == api.category:
				orig_name = api.guess_name()
				method_name = toObjCPropertyName(orig_name)
				cDict = {
					'orig_name': orig_name,
					'item_class': class_name,
					'path': str(api.path),
					'nsstring_path': str(re.sub(r'(\{\s*\w+\s*\})', '%@', api.path)),
					'description': str(api.description),
				}
				
				# synthesize the method name:
				#    getX:(block)callback
				#    getXForY:(NSString *)y callback:(block)callback
				usable = []
				
				# extract placeholders from the path
				placeholders = re.findall(r'\{\s*(\w+)\s*\}', api.path)
				guessed_item_id_name = orig_name.replace('get_', '')
				
				# put record-level getters in the array
				if 1 == len(placeholders) and 'record_id' == placeholders[0]:
					cDict['method_signature'] = '%s%s:%s' % (prefix, method_name, block_arg)
					_record_calls.append(cDict)
				
				# find the "get one item" methods (first param 'record_id', second 'item_id')
				elif 2 == len(placeholders) and 'record_id' == placeholders[0] \
					and '%s_id' % guessed_item_id_name == placeholders[1]:
					_single_item_calls.append(orig_name)
				
				# other class related calls: there currently are none and we're not doing anything with these
				else:
					for p in placeholders:
						if 'record_id' != p:
							argname = toObjCPropertyName(p)
							pname = argname if len(usable) > 0 else toObjCPropertyName('%s_for_%s' % (orig_name, p))
							usable.append('%s:(NSString *)%s' % (pname, argname))
					
					if len(usable) > 0:
						usable.append('callback:%s' % block_arg)
						cDict['method_name'] = ' '.join(usable)
					else:
						cDict['method_name'] = '%s:%s' % (toObjCPropertyName(orig_name), block_arg)
					
					#print '     %s: %s' % (a_class.name, cDict)
	
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


def read_template(template_name):
	"""Looks for a template with the given filename and returns its contents"""
	
	template_path = '%s/%s' % (_template_dir, template_name)
	if not os.path.exists(template_path):
		print 'xx>  No template could be found at %s' % template_path
		return None
	
	return open(template_path).read()


def apply_template(template, subst):
	"""Substitutes all values of the "subst" dictionary in the template with its
	values
	"""
	
	applied = template
	for k, v in subst.iteritems():
		applied = re.sub('\{\{\s*' + k + '\s*\}\}', v if v else '', applied)
	
	return applied


if __name__ == "__main__":
	"""Outputs Objective-C classes to be used in our iOS framework
	"""
	
	# the ontology file is not included in the python client, so we download it
	owl = None
	try:
		owl = download(_smart_ontology_uri, '.', 'smart.owl', False, True)
	except Exception, e:
		print 'xx>  Error downloading %s: %s' % (_smart_ontology_uri, e)
		sys.exit(1)
	
	if owl is None:
		print 'xx>  Error downloading %s' % _smart_ontology_uri
		sys.exit(1)
	
	# grab the template files
	templates = {}
	for f in ['ClassTemplate.h', 'ClassTemplate.m', 'CategoryTemplate.h', 'CategoryTemplate.m']:
		template = read_template(f)
		if template is None:
			print 'xx>  Failed to load template %s' % f
			sys.exit(1)
		
		templates[f] = template
	
	# parse the ontology
	print '-->  Parsing ontology'
	f = open(owl).read()
	rdf_ontology.parse_ontology(f)
	
	# prepare to grab classes
	if not os.path.exists(_generated_classes_dir):
		os.mkdir(_generated_classes_dir)
	if not os.access(_generated_classes_dir, os.W_OK):
		print "xx>  Can't write to %s" % _generated_classes_dir
		sys.exit(1)
	
	print '-->  Processing classes'
	known_classes = {}			# will be name: property-dictionary
	num_classes = 0
	num_calls = 0
	
	# loop all SMART_Class instances
	for o_class in rdf_ontology.api_types:
		if o_class.name in _classes_to_ignore:
			continue
		if o_class.name in known_classes:
			continue
		
		d = handle_class(o_class)
		if d:
			written = False
			
			# finish the header
			filename_h = '%s.h' % d['CLASS_NAME']
			path_h = os.path.join(_generated_classes_dir, filename_h)
			if _overwrite or not os.path.exists(path_h):
				header = apply_template(templates['ClassTemplate.h'], d)
				handle = open(path_h, 'w')
				handle.write(header)
				written = True
			
			# finish the implementation
			filename_m = '%s.m' % d['CLASS_NAME']
			path_m = os.path.join(_generated_classes_dir, filename_m)
			if _overwrite or not os.path.exists(path_m):
				implem = apply_template(templates['ClassTemplate.m'], d)
				handle = open(path_m, 'w')
				handle.write(implem)
				written = True
			
			if written:
				print '-->  Wrote class %s' % d['CLASS_NAME']
				num_classes += 1
	
	# put record-scoped calls into a record category
	used_call_names = _single_item_calls
	record_sigs = []
	record_calls = []
	for api in _record_calls:
		used_call_names.append(api['orig_name'])
		call = apply_template(_record_multi_item_getter_template, api)
		
		record_sigs.append('%s;' % api['method_signature'])
		record_calls.append(call)
	
	# war about the api calls that we did ignore
	for api in rdf_ontology.api_calls:
		orig_name = api.guess_name()
		if orig_name not in used_call_names:
			print 'xx>  Ignored API call: %s (level: %s)' % (orig_name, api.category)
	
	# write to SMRecord category
	if len(record_sigs) > 0:
		written = False
		record_sigs = sorted(record_sigs)
		record_calls = sorted(record_calls)
		now = datetime.date.today()
		d = {
			'CATEGORY_CLASS': 'SMRecord',
			'CATEGORY_NAME': 'Calls',
			'ONTOLOGY_PATH': 'smart.owl',
			'METHOD_SIGNATURES': "\n".join(record_sigs),
			'FULL_METHODS': "\n\n".join(record_calls),
			'AUTHOR': __file__,
			'DATE': str(now),
			'YEAR': str(now.year),
		}
		
		# write the header
		filename_h = '%s+%s.h' % (d['CATEGORY_CLASS'], d['CATEGORY_NAME'])
		path_h = os.path.join(_generated_classes_dir, filename_h)
		if _overwrite or not os.path.exists(path_h):
			header = apply_template(templates['CategoryTemplate.h'], d)
			handle = open(path_h, 'w')
			handle.write(header)
			written = True
		
		# finish the implementation
		filename_m = '%s+%s.m' % (d['CATEGORY_CLASS'], d['CATEGORY_NAME'])
		path_m = os.path.join(_generated_classes_dir, filename_m)
		if _overwrite or not os.path.exists(path_m):
			implem = apply_template(templates['CategoryTemplate.m'], d)
			handle = open(path_m, 'w')
			handle.write(implem)
			written = True
		
		if written:
			print '-->  Wrote category %s on %s' % (d['CATEGORY_NAME'], d['CATEGORY_CLASS'])	
			num_calls += 1
	
	# all done
	print '-->  Done. %d classes and %d categories written.' % (num_classes, num_calls)

