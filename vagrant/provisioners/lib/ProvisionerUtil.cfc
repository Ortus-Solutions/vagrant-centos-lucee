component {

	/****************************************************
	*  Remove previous config 
	****************************************************/
	function removePreviousConfig() {
		// Clean up old Nginx site configs
		directoryDelete( '/etc/nginx/sites/', true )
		directoryCreate( '/etc/nginx/sites/' )
		
		// Mappings? Datasources? Bueller? BUELLER?
	}

	/****************************************************
	*  Get site configs by convention
	*
	*  Look for "VagrantConfig.yaml" files in
	*  the root of other repos cloned in the same dir 
	***************************************************/
	function getSiteConfigs() {
		var configs = []
		// get a list of all the other repos checked out in the same dir as our Vagrant setup
		var repos = directoryList( '/vagrant-parent' )
		for( var repo in repos ) {
			var configDir = repo & '/VagrantConfig'
			// See if they have a "VagrantConfig" folder in them
			if( directoryExists( configDir ) ) {
				var configsInThisRepo = directoryList( configDir )
					configs.append( configsInThisRepo, true )
			}
		}
		return configs
	}

	/****************************************************
	*  Setup Nginx server
	****************************************************/
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
	
	/****************************************************
	*  Create CF mappings in the server
	*
	*  <mapping
	*		inspect-template=""
	*		physical="/var/www"
	*		primary="physical"
	*		toplevel="true"
	*		virtual="/foo"/>
	*
	****************************************************/
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
	
	/****************************************************
	*  Write dynamic default index that 
	*  lists out the configured sites
	****************************************************/
	function writeDefaultIndex( siteConfigs ) {
		var defaultSiteIndex = fileRead( '/var/wwwDefault/index.cfm' )
		
		saveContent variable='local.siteList' {
			include '/var/wwwDefault/siteList.cfm';
		}
		defaultSiteIndex = replaceNoCase( defaultSiteIndex, '@@siteList@@', siteList )
		fileWrite( '/var/www/index.cfm', defaultSiteIndex )
	}
		
	/****************************************************
	*  Clean up site name for file system
	****************************************************/
	function slugifySiteName( str ) {
		var slug = lcase(trim(arguments.str))
		slug = reReplace(slug,"[^a-z0-9-\s]","","all")
		slug = trim ( reReplace(slug,"[\s-]+", " ", "all") )
		slug = reReplace(slug,"\s", "-", "all")
		return slug
	}

	/****************************************************
	*  Custom echo that also appends to 
	*  install log and adds line feed
	****************************************************/	
	function _echo( message ) {
		message &= chr(10)
		echo( message )
		fileAppend( '/vagrant/log/install.txt', message )
	}

	/****************************************************
	*  Convert path segment relative to 
	*  repo root into a full path
	****************************************************/	
	function convertPath( path, configPath ) {
		// Standardize and remove leading/trailing slashes
		var path = listChangeDelims( path, '/', '/\' )
		// Root of the repo which the path above is relative to
		var repoRoot = reReplaceNoCase( configPath, 'VagrantConfig/[^\.]*.yaml', '' )
		return repoRoot & path 
	}
	
}