<cfoutput>
	<cfif structCount( siteConfigs ) >
		<div class="header">
			<h3>
				Here are the sites configured on your VM.
			</h3>
			<h4>
				Run "vagrant reload --provision" after adding or removing repos.
			</h4>
		</div>
		<cfloop collection="#siteConfigs#" item="configPath">
			<div class="site">
				<cfset siteConfig = siteConfigs[ configPath ]>
				<cfif siteConfig.error >
					<h2 style="color:red">#configPath#</h2>
					<p>Oh snap, something went wrong configuring this site. Here's the details:</p>
					<cfdump var="#siteConfig.errorStruct#" expand="no">
				<cfelse>
					<h2>#siteConfig.name#</h2>
					<ul>
					<cfloop array="#siteConfig.domains#" index="domain">
						<li><a href="http://#domain#">#domain#</a></li>
					</cfloop>
					</ul>
				</cfif>
			</div>
		</cfloop>
	<cfelse>
		<h3>
			There are no sites configured.  Make sure they are checked out in the same folder as the Vagrant repo and have a VagrantConfig folder with one or more YAML files.
		</h3>
	</cfif>
</cfoutput>