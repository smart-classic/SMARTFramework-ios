#
#	Creates Objective-C classes from our ontology.
#

### config ###
_obj_c_class_prefix = 'SM'
_generated_classes_dir = 'SMARTFramework/GeneratedClasses'
_smart_ontology_uri = 'https://raw.github.com/chb/smart_common/adding-0.5-models/schema/smart.owl'


### there's probably no need to edit anything beyond this line ###
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
		print 'xx>	%s is already known, skipping' % a_class.name
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
	properties = []
	for o_prop in a_class.object_properties:
		# o_prop.multiple_cardinality   ->  Bool whether the property can have multiple items
		# o_prop.to_class			    ->  SMART_Class represented by the property
		# o_prop.to_class.uri   	  	->  Class URI
		prop = {
			'name': toObjCPropertyName(o_prop.name),
			'uri': o_prop.uri,
			'multi': o_prop.multiple_cardinality,
			'itemClass': toObjCClassName(o_prop.to_class.name),
			'strength': 'strong',
		}
		properties.append(prop)
	
	# get data properties (OWL_DataProperty instances)
	for d_prop in a_class.data_properties:
		primitive = 'NSString'			# TODO: When to use NSNumber or NSDate?
		prop = {
			'name': toObjCPropertyName(d_prop.name),
			'uri': d_prop.uri,
			'multi': d_prop.multiple_cardinality,
			'itemClass': primitive,
			'strength': 'copy',
		}
		properties.append(prop)
	
	# loop properties to create their statements and getter
	prop_statements = []
	prop_getter = []
	for p in properties:
		strength = 'copy' if p['multi'] else p['strength']
		cls = 'NSArray' if p['multi'] else p['itemClass']
		
		# the property statement
		stmt = '/// Representing %s\n@property (nonatomic, %s) %s *%s;'
		prop_statements.append(stmt % (p['uri'], strength, cls, p['name']))
		
		# TODO: create the getter
		# ...
	
	myDict['CLASS_PROPERTIES'] = "\n\n".join(prop_statements)
	
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
		
		# testing with "Demographics" and "Name"
		if 'Demographics' == o_class.name \
			or 'Name' == o_class.name:
			d = handle_class(o_class, known_classes)
			
			if d:
				filename_h = '%s.h' % d['CLASS_NAME']
				path_h = os.path.join(_generated_classes_dir, filename_h)
				if os.path.exists(path_h):
					print 'xx>  Class %s already exists at %s, skipping' % (d['CLASS_NAME'], path_h)
					continue
				
				filename_m = '%s.m' % d['CLASS_NAME']
				path_m = os.path.join(_generated_classes_dir, filename_m)
				if os.path.exists(path_m):
					print 'xx>  Implementatino for %s already exists at %s, skipping' % (d['CLASS_NAME'], path_m)
					continue
				
				# finish the header
				header = apply_template(template_h, d)
				print header
				
				# finish the implementation
				implem = apply_template(template_m, d)
				print implem
				
				num_generated += 1
	
	# all done
	print '-->  Done. %d classes written.' % num_generated

