<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">

	<xsl:template match="/FxCopReport">
		<html>
			<head>
				<title>Analysis Report</title>
			</head>
			<style>
				#Title {font-family: Verdana; font-size: 14pt; color: black; font-weight: bold}
				.ColumnHeader {font-family: Verdana; font-size: 8pt; background-color:white; color: black}
				.CriticalError {font-family: Verdana; font-size: 8pt; color: darkred; font-weight: bold; text-align: center}
				.Error {font-family: Verdana; font-size: 8pt; color: royalblue; font-weight: bold; text-align: center}
				.CriticalWarning {font-family: Verdana; font-size: 8pt; color: green; font-weight: bold; text-align: center}
				.Warning {font-family: Verdana; font-size: 8pt; color: darkgray; font-weight: bold; text-align: center}
				.Information {font-family: Verdana; font-size: 8pt; color: black; font-weight: bold; text-align: center}

				.PropertyName {font-family: Verdana; font-size: 8pt; color: black; font-weight: bold}
				.PropertyContent {font-family: Verdana; font-size: 8pt; color: black}
				.NodeIcon { font-family: WebDings; font-size: 12pt; color: navy; padding-right: 5;}
				.MessagesIcon { font-family: WebDings; font-size: 12pt; color: red;}
				.RuleDetails { padding-top: 10;}
				.SourceCode { background-color:#DDDDFF; }
				.RuleBlock { background-color:#EEEEFF; }
				.MessageNumber { font-family: Verdana; font-size: 10pt; color: darkred; }
				.MessageBlock { font-family: Verdana; font-size: 10pt; color: darkred; }
				.Resolution {font-family: Verdana; font-size: 8pt; color: black; }
				.NodeLine { font-family: Verdana; font-size: 9pt;}
				.Note { font-family: Verdana; font-size: 9pt; color:black; background-color: #DDDDFF; }
				.NoteUser { font-family: Verdana; font-size: 9pt; font-weight: bold; }
				.NoteTime { font-family: Verdana; font-size: 8pt; font-style: italic; }
				.Button { font-family: Verdana; font-size: 9pt; color: blue; background-color: #EEEEEE; }
			</style>
			<script>
				function ViewState(blockId)
				{
				var block = document.getElementById(blockId);
				if (block.style.display=='none')
				{
				block.style.display='block';
				}
				else
				{
				block.style.display='none';
				}
				}

				function SwitchAll(how)
				{
				var nodes = document.getElementsByTagName("div");
				for (i = 0; i != nodes.length;i++)
				{
				var block = nodes[i];
				if (block != null)
				{
				if (block.className == 'NodeDiv'
				|| block.className == 'MessageBlockDiv'
				|| block.className == 'MessageDiv')
				{
				block.style.display=how;
				}
				}
				}
				}

				function ExpandAll()
				{
				SwitchAll('block');
				}

				function CollapseAll()
				{
				SwitchAll('none');
				}
			</script>
			<body bgcolor="white" alink="Black" vlink="Black" link="Black">

				<!-- Report Title -->
				<div id="Title">
					FxCop
					<xsl:value-of select="@Version"/>
					Analysis Report
				</div>
				<br/>
				<table>
					<tr>
						<td class="Button">
							<a onClick="ExpandAll();">Expand All</a>
						</td>
						<td class="Button">
							<a onClick="CollapseAll();">Collapse All</a>
						</td>
					</tr>
				</table>
				<br/>
				<xsl:apply-templates select="Namespaces"/>
				<xsl:choose>
					<xsl:when test="Namespaces">
						<hr/>
					</xsl:when>
				</xsl:choose>
				<xsl:apply-templates select="Targets"/>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="*">
		<xsl:choose>
			<xsl:when test="@Name or name()='Resources'">
				<xsl:variable name="MessageCount" select="count(.//Message[@Status='Excluded'])"/>
				<xsl:choose>
					<xsl:when test="$MessageCount > 0">
						<xsl:variable name="nodeId" select="generate-id()"/>
						<div class="NodeLine">

							<xsl:attribute name="onClick">
								javascript:ViewState('<xsl:value-of select="$nodeId"/>');
							</xsl:attribute>

							<!-- Display Icon -->
							<xsl:choose>
								<xsl:when test="name()='Member' and @Kind='Method'">
									<nobr class="NodeIcon">&#x0061;</nobr>
								</xsl:when>
								<xsl:when test="name()='Member' and @Kind='Constructor'">
									<nobr class="NodeIcon">&#x003D;</nobr>
								</xsl:when>
								<xsl:when test="name()='Member' and @Kind='Property'">
									<nobr class="NodeIcon">&#x0098;</nobr>
								</xsl:when>
								<xsl:when test="name()='Member' and @Kind='Event'">
									<nobr class="NodeIcon">&#x007E;</nobr>
								</xsl:when>
								<xsl:when test="name()='Member' and @Kind='Field'">
									<nobr class="NodeIcon">&#x00EB;</nobr>
								</xsl:when>
								<xsl:when test="name()='Type' and @Kind='Class'">
									<nobr class="NodeIcon">&#x003C;</nobr>
								</xsl:when>
								<xsl:when test="name()='Type' and @Kind='Interface'">
									<nobr class="NodeIcon">&#x003C;</nobr>
								</xsl:when>
								<xsl:when test="name()='Type' and @Kind='Delegate'">
									<nobr class="NodeIcon">&#x003C;</nobr>
								</xsl:when>
								<xsl:when test="name()='Type' and @Kind='Enum'">
									<nobr class="NodeIcon">&#x003C;</nobr>
								</xsl:when>
								<xsl:when test="name()='Type' and @Kind='Struct'">
									<nobr class="NodeIcon">&#x003C;</nobr>
								</xsl:when>
								<xsl:when test="name()='Namespace'">
									<nobr style="color: navy;">{}</nobr>
								</xsl:when>
								<xsl:when test="name()='Target'">
									<nobr class="NodeIcon">&#x0032;</nobr>
								</xsl:when>
								<xsl:when test="name()='Module'">
									<nobr class="NodeIcon">&#x0031;</nobr>
								</xsl:when>
								<xsl:when test="name()='Resource'">
									<nobr class="NodeIcon">&#x009D;</nobr>
								</xsl:when>
								<xsl:when test="name()='Resources'">
									<nobr class="NodeIcon">&#x00CC;</nobr>
								</xsl:when>
								<xsl:otherwise>
									[<xsl:value-of select="name()"/>]
								</xsl:otherwise>
							</xsl:choose>

							<xsl:choose>
								<xsl:when test="name()='Resources'">
									<xsl:value-of select="name()"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="@Name"/>
								</xsl:otherwise>
							</xsl:choose>
							<nobr class="MessageNumber">
								(<xsl:value-of select="$MessageCount"/>)
							</nobr>
						</div>

						<div class="NodeDiv" style="display: none; position: relative; padding-left: 11;">
							<xsl:attribute name="id">
								<xsl:value-of select="$nodeId"/>
							</xsl:attribute>

							<xsl:apply-templates/>
						</div>

					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="Messages">
		<xsl:variable name="MessageBlockId" select="generate-id()"/>
		<div class="MessageBlock">
			<xsl:attribute name="onClick">
				javascript:ViewState('<xsl:value-of select="$MessageBlockId"/>');
			</xsl:attribute>
			<nobr class="MessagesIcon">&#x0040;</nobr>
			<xsl:variable name="MessageCount" select="count(Message[@Status='Excluded'])"/>
			<xsl:value-of select="$MessageCount"/>
			Message
			<xsl:choose>
				<xsl:when test="$MessageCount > 1">s</xsl:when>
			</xsl:choose>
			for
			<xsl:value-of select="../@Name"/>
		</div>
		<div class="MessageBlockDiv" style="display: none; position: relative; padding-left: 5;">
			<xsl:attribute name="id">
				<xsl:value-of select="$MessageBlockId"/>
			</xsl:attribute>

			<table width="100%">
				<tr>
					<td class="ColumnHeader">Message Level</td>
					<td class="ColumnHeader">Certainty</td>
					<td class="ColumnHeader" width="100%">Resolution</td>
				</tr>
				<xsl:apply-templates select="Message[@Status='Excluded']"/>
			</table>
		</div>

	</xsl:template>

	<xsl:template match="Message">

		<!-- Message Row -->

		<xsl:variable name="messageId" select="generate-id()"/>
		<xsl:variable name="rulename" select="TypeName"/>

		<xsl:apply-templates select="Issue">
			<xsl:with-param name="messageId">
				<xsl:value-of select="$messageId"/>
			</xsl:with-param>
		</xsl:apply-templates>

		<tr>
			<td colspan="3">
				<div class="MessageDiv" style="display: none">
					<xsl:attribute name="id">
						<xsl:value-of select="$messageId"/>
					</xsl:attribute>

					<!--- Rule Details  -->
					<table width="100%" class="RuleBlock">
						<xsl:apply-templates select="Notes" mode="notes"/>
						<xsl:apply-templates select="/FxCopReport/Rules/Rule[@TypeName=$rulename]" mode="ruledetails"/>
					</table>
				</div>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="Issue">
		<xsl:param name="messageId"></xsl:param>
		<tr>
			<xsl:attribute name="onClick">
				javascript:ViewState('<xsl:value-of select="$messageId"/>');
			</xsl:attribute>

			<xsl:attribute name="bgcolor">
				<xsl:choose>
					<xsl:when test="position() mod 2 = 1">#EEEEEE</xsl:when>
					<xsl:otherwise>white</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>

			<td valign="top">
				<xsl:attribute name="class">
					<xsl:value-of select="@Level"/>
				</xsl:attribute>
				<xsl:value-of select="@Level"/>
			</td>
			<td valign="top">
				<xsl:attribute name="class">
					<xsl:value-of select="@Level"/>
				</xsl:attribute>
				<xsl:value-of select="@Certainty"/>
			</td>
			<td class="Resolution" valign="top">
				<xsl:value-of select="text()"/>
			</td>
		</tr>
		<xsl:if test="@Path">
			<tr class="SourceCode">
				<td class="PropertyName">Source:</td>
				<td class="PropertyContent" colspan="2">
					<a>
						<xsl:attribute name="href">
							<xsl:value-of select="@Path"/>\
							<xsl:value-of select="@File"/>
						</xsl:attribute>
						<xsl:value-of select="@Path"/>\
						<xsl:value-of select="@File"/>
					</a>
					(Line<xsl:value-of select="@Line"/>)
				</td>
			</tr>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Notes" mode="notes">
		<xsl:apply-templates select="User" mode="notes"/>
	</xsl:template>

	<xsl:template match="User" mode="notes">
		<tr class="Note">
			<td class="Note">
				<nobr class="NoteUser">
					<xsl:value-of select="@Name"/>
				</nobr>
				&#160;
				<xsl:apply-templates select="Note" mode="notes">
					<xsl:with-param name="username">
						<xsl:value-of select="@Name"/>
					</xsl:with-param>
				</xsl:apply-templates>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="Note" mode="notes">
		<xsl:param name="username"></xsl:param>
		<xsl:variable name="id" select="@Id"/>
		<xsl:apply-templates select="/FxCopReport/Notes/User[@Name=$username]/Note[@Id=$id]" mode="notesPointer"/>
	</xsl:template>


	<xsl:template match="Note" mode="notesPointer">
		<td colspan="2" class="Note">
			<nobr class="NoteTime">[<xsl:value-of select="@Modified"/>]
			</nobr>
			:
			<xsl:value-of select="."/>
		</td>
	</xsl:template>

	<xsl:template match="Description" mode="ruledetails">
		<tr>
			<td class="PropertyName">Rule Description:</td>
			<td class="PropertyContent">
				<xsl:value-of select="text()"/>
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="LongDescription" mode="ruledetails">
		<!-- Test, don't display line if no data present -->
		<xsl:choose>
			<xsl:when test="text()">
				<tr>
					<td class="PropertyName">Long Description:</td>
					<td class="PropertyContent">
						<xsl:value-of select="text()"/>
					</td>
				</tr>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="File" mode="ruledetails">
		<tr>
			<td class="PropertyName">Rule File:</td>
			<td class="PropertyContent">
				<xsl:value-of select="@Name"/>
				[<xsl:value-of select="@Version"/>]
			</td>
		</tr>
	</xsl:template>

	<xsl:template match="Rule" mode="ruledetails">
		<tr>
			<td class="PropertyName">Rule:</td>
			<td class="PropertyContent">
				<xsl:value-of select="Name"/>
			</td>
		</tr>
		<tr>
			<td class="PropertyName">Category:</td>
			<td class="PropertyContent">
				<xsl:value-of select="Category"/>
			</td>
		</tr>
		<tr>
			<td class="PropertyName">Check Id:</td>
			<td class="PropertyContent">
				<xsl:value-of select="CheckId"/>
			</td>
		</tr>
		<xsl:apply-templates select="Description" mode="ruledetails"/>
		<xsl:apply-templates select="File" mode="ruledetails"/>
	</xsl:template>

	<!-- End Rule Details -->

</xsl:stylesheet>
