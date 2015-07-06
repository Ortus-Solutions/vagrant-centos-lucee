#!/usr/bin/env box
<cftry>
<cfscript>

	// A library for parsing YAML
	YAMLParser = new vagrant.cfml.lib.YAMLParser()
	
	_echo( '' )
	_echo( "================= START CONFIGURE-SITES.SH #now()# =================" )
	_echo( '' )
	
	//Clean up previous mess
	removePreviousConfig()
	
	// Get all the YAML configs
	siteConfigPaths = getSiteConfigs()
	siteConfigs = {}
	
	// Loop over each sites' config
	for( siteConfigPath in siteConfigPaths ) {
	
		// Default site name to config path for error logging in case we never made it past the parsing
		siteName = siteConfigPath
	
		// Configure each site in a try/catch so if one errors, the rest can still complete	
		try {
			// Parse the YAML
			config = YAMLParser.yamlToCfml( fileRead( siteConfigPath ) )
			siteName = config['name']
			
			// Set up the Nginx servers
			configureNginx( config, siteConfigPath )
			
			// Process the CF mappings 
			configureMappings( config, siteConfigPath )
		
			// Add error=false to the config struct for the index page we'll create that lists all the sites
			siteConfigs[ siteConfigPath ] = { 'error' : false }.append( config )
						
			_echo( "" )	
		} catch( Any e ) { 
			_echo( "================= Error configuring site '#siteName#'.  Error to follow. =================" )
			_echo( e.message )
			_echo( e.detail )
			_echo( e.stackTrace )
			_echo( "================= end '#siteName#' error =================" )
			
			// If configuration failed, flag it and add the error struct.
			siteConfigs[ siteConfigPath ] = { 'error' : true, 'errorStruct' : e }
		}
	}
	
	// Write out an index page for the default site that will list all the apps we configured on the VM
	writeDefaultIndex( siteConfigs )
		
	_echo( '' )
	_echo( "================= FINISH CONFIGURE-SITES.SH #now()# =================" )
	_echo( '' )


	//////////////////////////////////////////////////////
	//  Remove previous config 
	/////////////////////////////////////////////////////
	function removePreviousConfig() {
		// Clean up old Nginx site configs
		directoryDelete( '/etc/nginx/sites/', true )
		directoryCreate( '/etc/nginx/sites/' )
		
		// Mappings? Datasources? Bueller? BUELLER?
	}



	//////////////////////////////////////////////////////
	//  Get site configs by convention
	//
	//  Look for "VagrantConfig.yaml" files in
	//  the root of other repos cloned in the same dir 
	/////////////////////////////////////////////////////
	function getSiteConfigs() {
		var configs = []
		var dirs = directoryList( '/vagrant-parent' )
		for( var dir in dirs ) {
			configFile = dir & '/VagrantConfig.yaml'
			if( fileExists( configFile ) ) {
				configs.append( configFile )
			}
		}
		return configs
	}


	/////////////////////////////////////
	//  Setup Nginx server
	/////////////////////////////////////
	function configureNginx( config, siteConfigPath ) {
		var webRoot = convertPath( config['webroot'], siteConfigPath )
		
		// Read in our Nginx template file
		var siteTemplate = fileRead( '/vagrant/configs/site-template.conf' )
		// Swap out the dynamic parts
		siteTemplate = replaceNoCase( siteTemplate, '@@webroot@@', webRoot )
		siteTemplate = replaceNoCase( siteTemplate, '@@domains@@', arrayToList( config['domains'], ' ' ) )
		
		// Write it back out
		var fileName = '/etc/nginx/sites/#slugifySiteName( config[ 'name' ] )#.conf' 
		fileWrite( fileName, siteTemplate )
		
		_echo( "Added Nginx site #fileName#" )
	}
	
	///////////////////////////////////////
	//  Create CF mappings in the server
	//
	//  <mapping
	//		inspect-template=""
	//		physical="/var/www"
	//		primary="physical"
	//		toplevel="true"
	//		virtual="/foo"/>
	//
	///////////////////////////////////////
	function configureMappings( config, siteConfigPath ) {
		// Adding this to the server context.   Might need to add to the web context, but would need to 
		// do some magic since WEB-INFs wouldn't be created yet
		serverXML = XMLParse( fileRead( '/opt/lucee/lib/lucee-server/context/lucee-server.xml' ) )
		for( var mapping in config[ 'cfmappings' ] ) {
			
			var found = false
			
			// Check for existing
			for( var child in serverXML.cfLuceeConfiguration.mappings.XmlChildren ) {
				if( child.xmlName == 'mapping' && child.XmlAttributes.virtual == trim( mapping[ 'virtual' ] ) ) {
					found = true
					break;
				}
			}
			
			if( found ) { continue; }
			
			var newMapping = XmlElemNew( serverXML, 'mapping' )
			newMapping.XmlAttributes[ 'inspect-template' ] = ''
			newMapping.XmlAttributes[ 'physical' ] = convertPath( trim( mapping[ 'physical' ] ), siteConfigPath )
			newMapping.XmlAttributes[ 'primary' ] = 'physical'
			newMapping.XmlAttributes[ 'toplevel' ] = 'true'
			newMapping.XmlAttributes[ 'virtual' ] = trim( mapping[ 'virtual' ] )
			
			serverXML.cfLuceeConfiguration.mappings.XmlChildren.append( newMapping )
			
			fileWrite( '/opt/lucee/lib/lucee-server/context/lucee-server.xml', toString( serverXML )  )
			
			_echo( "Added CF Mapping #mapping[ 'virtual' ]#" )
			
		}
		
	}
	
	////////////////////////////////////////
	//  Write dynamic default index that 
	//  lists out the configured sites
	////////////////////////////////////////
	function writeDefaultIndex( siteConfigs ) {
		var defaultSiteIndex = fileRead( '/var/wwwDefault/index.cfm' )
		
		saveContent variable='local.siteList' {
			include '/vagrant/cfml/siteList.cfm';
		}
		defaultSiteIndex = replaceNoCase( defaultSiteIndex, '@@siteList@@', siteList )
		fileWrite( '/var/www/index.cfm', defaultSiteIndex )
	}
	
	
	////////////////////////////////////////
	//  Clean up site name for file system
	////////////////////////////////////////
	function slugifySiteName( str ) {
		var slug = lcase(trim(arguments.str))
		slug = reReplace(slug,"[^a-z0-9-\s]","","all")
		slug = trim ( reReplace(slug,"[\s-]+", " ", "all") )
		slug = reReplace(slug,"\s", "-", "all")
		return slug
	}

	////////////////////////////////////////
	//  Custom echo that also appends to 
	//  install log and adds line feed
	////////////////////////////////////////	
	function _echo( message ) {
		message &= chr(10)
		echo( message )
		fileAppend( '/vagrant/log/install.txt', message )
	}

	////////////////////////////////////////
	//  Convert path segment relative to 
	//  repo root into a full path
	////////////////////////////////////////	
	function convertPath( path, configPath ) {
		// Standardize and remove leading/trailing slashes
		var path = listChangeDelims( path, '/', '/\' )
		// Root of the repo which the path above is relative to
		var repoRoot = replaceNoCase( configPath, 'VagrantConfig.yaml', '' )
		return repoRoot & path 
	}
	
</cfscript>
<cfcatch>
	<cfdump var="#cfcatch#" format="text">
</cfcatch>
</cftry>