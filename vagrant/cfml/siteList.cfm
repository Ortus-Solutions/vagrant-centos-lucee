<cfoutput>
	<cfif structCount( siteConfigs ) >
		<p><strong>Here are the sites configured on your VM.  Run "vagrant provision" after adding or removing repos.</strong></p>
		<cfloop collection="#siteConfigs#" item="configPath">
			<cfset siteConfig = siteConfigs[ configPath ]>
			<cfif siteConfig.error >
				<h2 style="color:red">#configPath#</h2>
				Oh snap, something went wrong configuring this site. Here's the details:
				<cfdump var="#siteConfig.errorStruct#" expand="no">
			<cfelse>
				<h2>#siteConfig.name#</h2>
				<ul>
				<cfloop array="#siteConfig.domains#" index="domain">
					<li><a href="http://#domain#">#domain#</a></li>
				</cfloop>
				</ul>
			</cfif>
		</cfloop>
	<cfelse>
		<p><strong>There are no sites configured.  Make sure they are checked out in the same folder as the Vagrant repo and have a "VagrantConfig.yaml" in their root.</strong></p>
	</cfif>
</cfoutput>