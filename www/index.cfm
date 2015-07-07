<html>
<head>
	<title>custom dev</title>
	<style type="text/css">
		body{
			background-color: #2F89BF;
			font-family: verdana, arial, sans-serif;
		}
		.wrap{
			margin:48px;
			padding: 24px;
		}
		.header{
			background-color: #fff;
			margin: 18px;
			padding: 18px;
			text-align: center;
		}
		.site{
			background-color: #fff;
			border: 1px solid #ccc;
			margin: 18px;
			padding: 0 18px;
		}
		h1, h2, h3{
			color: #777;
		}
	</style>
</head>
<body>

	<div class="wrap">
		<div class="header">
			<div style="text-align:center">
				<img src="/includes/logo.jpg">
				<p>custom development environment</p>
			</div> 
			<h1>Congrats, your local environment is up and running!</h1>
			<cfoutput>#dateFormat( now(), "full" )#</cfoutput>
			<p>
				Access the Lucee Server Administrator at: <a href="/lucee/admin/server.cfm">/lucee/admin/server.cfm</a>
			</p>
			
		</div>
		
@@siteList@@

	</div>
</body>
</html>
