<#-- Documentation: http://pscodelibrary.stage.lithium.com/t5/Customizations/Common-Functions/ta-p/6 -->
<#include "theme-lib.common-variables.ftl" />
 
<#function hasQueryResults res>
 <#return res?? && res.status?? && res.status == "success" && res.data?? && res.data.size gt 0 && res.data.items?? && res.data.items?has_content />
</#function>
 
<#-- TODO: Convert to LiQL.  Investigate caching. -->
<#function userHasRole userId roleName>
 <#local roles = restadmin("/users/id/${userId}/roles").roles />
 <#local hasRole = false />
 <#list roles.role as role>
   <#-- always check role against the top level -->
   <#if role.name?string == roleName?string && role.node.@type == "community">
     <#local hasRole = true />
     <#break />
   </#if>
 </#list>
 <#return hasRole />
</#function>
 
<#function userRoleIn userId roleNames>
 <#local hasRole = false />
 <#local roleNamesSplit = roleNames?split(",") />
 <#local qry = "SELECT id FROM roles WHERE users.id = '${userId}'" />
 <#local roles = executeLiQLQuery(qry, false, true) />
 <#if roles?size gt 0>
   <#list roles as role>
     <#list roleNamesSplit as roleName>
       <#if role.id == roleName>
         <#local hasRole = true />
         <#break />
       </#if>
     </#list>
     <#if hasRole>
       <#break />
     </#if>
   </#list>
 </#if>
 <#return hasRole />
</#function>
 
<#-- TODO:  Add "sanitize string" func -->
 
<#function executeLiQLQuery qry isCount=false executeAsAdmin=false charSet="UTF-8">
 <#if isCount>
   <#if executeAsAdmin>
     <#return (restadmin(API_VERSION, "/search?q=" + qry?url(charSet) + "&restapi.response_style=view").data.count)!0 />
   <#else>
     <#return (rest(API_VERSION, "/search?q=" + qry?url(charSet) + "&restapi.response_style=view").data.count)!0 />
   </#if>
 <#else>
   <#if executeAsAdmin>
     <#return (restadmin(API_VERSION, "/search?q=" + qry?url(charSet) + "&restapi.response_style=view").data.items)![] />
   <#else>
     <#return (rest(API_VERSION, "/search?q=" + qry?url(charSet) + "&restapi.response_style=view").data.items)![] />
   </#if>
 </#if>
</#function>
 
<#--
 
USAGE:
<@generateComponentContent className="custom-mystats" key="custom.mystats.title" additionalClasses="custom-component" viewAll=statsUser.@view_href!"" >
   YOUR CONTENT HERE
</@generateComponentContent>
 
-->
<#macro generateComponentContent className componentTitleKey="" additionalClasses="" viewAll="">
 <div class="lia-panel lia-panel-standard ${className} ${additionalClasses}">
   <div class="lia-decoration-border">
     <div class="lia-decoration-border-top"><div> </div></div>
     <div class="lia-decoration-border-content">
       <div>
         <#if componentTitleKey?trim?length gt 0>
           <div class="lia-panel-heading-bar-wrapper">
             <div class="lia-panel-heading-bar">
               <span class="lia-panel-heading-bar-title">${text.format(componentTitleKey)}</span>
             </div>
           </div>
         </#if>
         <div class="lia-panel-content-wrapper">
           <div class="lia-panel-content">
             <#nested />
           </div>
           <#if viewAll?? && viewAll?trim?has_content>
             <div class="lia-view-all">
               <a class="lia-link-navigation" href="${viewAll!""}">${text.format("general.View_All")}</a>
             </div>
           </#if>
         </div>
       </div>
     </div>
     <div class="lia-decoration-border-bottom">
       <div> </div>
     </div>
   </div>
 </div>
</#macro>
 
<#--
USAGE:
getRequstField (paramName, defaultValue, stripTags)
fieldName: the name of the request parameter to check
defaultValue: if request parameter is missing, the value to use (default is empty string)
stringTags: should tags be removed from the data (default true)
 
Possible error codes:  STATUS_ERROR_INVALID_NUMBER, STATUS_ERROR_INVALID_OBJECT
-->
 
<#function getRequestField paramName defaultValue="" isNumber=false stripTags=true htmlStripRules=false>
 <#local cleanData = http.request.parameters.name.get(paramName, defaultValue)?trim />
 <#if isNumber>
   <#attempt>
     <#local cleanData = cleanData?number?c />
   <#recover>
     ${utils.logs.name.common_functions.error("getRequstField expected a number. " + STATUS_ERROR_INVALID_NUMBER)}
     <#return STATUS_ERROR_INVALID_NUMBER />
   </#attempt>
 <#else>
   <#if stripTags>
     <#local cleanData = dataSanitizer(cleanData) />
   <#else>
     <#local cleanData = dataSanitizer(cleanData, true, htmlStripRules) />
   </#if>
 </#if>
 <#return cleanData />
</#function>
 
<#--
USAGE:
dataSanitizer (paramName, defaultValue, stripTags)
allowHTML: should the data contain HTML tags (default false)
optionsBuilder: if html allowed, user can pass optionsBuilder object with tag rules (default is false meaning no strip options object)
-->
 
<#function dataSanitizer dataStr allowHTML=false optionsBuilder=false>
 <#local cleanData = "" />
 <#if allowHTML>
   <#-- if optionsBuilder is a boolean, it isn't a valid optionsBuilder object, so don't use one. -->
   <#if optionsBuilder?is_boolean>
     <#-- allow common elements, since "allow html" was set to true"  -->
     <#local stripperOptions = utils.html.stripper.from.owasp.optionsBuilder.allowCommonBlockElements().allowCommonInlineFormattingElements().build() />
     <#local cleanData = utils.html.stripper.from.owasp.strip(dataStr, stripperOptions) />
   <#else>
     <#-- if user supplied an optionsBuilder object, use it. If invalid object, log and return invalid object string. -->
     <#attempt>
       <#local cleanData = utils.html.stripper.from.owasp.strip(dataStr, optionsBuilder) />
     <#recover>
       ${utils.logs.name.common_functions.error("dataSanitizer error stripping tags from data. owasp.newOptionsBuilder is invalid. ")}
       <#return STATUS_ERROR_INVALID_OBJECT />
     </#attempt>
   </#if>
 <#else>
    <#local cleanData = utils.html.stripper.from.owasp.strip(dataStr) />
 </#if>
 <#return cleanData />
</#function>
 
<#function getUserCSRFToken>
 <#-- This code is used to prevent CSRF attacks. -->
 <#if usercache.get("csrfToken", "") == "">
   <#local csrfToken = utils.numbers.randomLong />
   <#local ret = usercache.put("csrfToken", csrfToken?string) />
 </#if>
 <#return usercache.get("csrfToken", "") />
 <#-- End CSRF code. -->
</#function>
 
<#function getEndpointUrl endpointName>
  <#local endPointUrl = webuisupport.urls.endpoints.name.get(endpointName).query("tid",getUserCSRFToken()).build() />
  <#local servicePath = config.getString("webserver.servicePathChar","") />
  <#if servicePath != "">
	<#local servicePath = "/" + servicePath />
    <#local endPointUrl = community.urls.tapestryPrefix + servicePath + endPointUrl />
  </#if>
  <#return endPointUrl />
</#function>
 
<#function validCSRFToken>
 <#local csrfToken1 = http.request.parameters.name.get("tid", "") />
 <#local csrfToken2 = usercache.get("csrfToken", "") />
 <#if csrfToken1 != "" && csrfToken2 != "" && csrfToken1 == csrfToken2>
   <#return true />
 <#else>
   <#return false />
 </#if>
</#function>
 
<#function validEndpointRequest allowGet=false allowHttp=false allowExternal=false>
 <#if !validCSRFToken()>
   <#local warningResult = logWarning("Invalid CSRFToken") />
   <#return false />
</#if>
 
 <#if !allowGet && http.request.method != "POST">
   <#local warningResult = logWarning("Invalid request method: ${(http.request.method)!''}") />
   <#return false />
 </#if>
 
 <#if !allowHttp && !(http.request.ssl)>
   <#local warningResult = logWarning("Request made without SSL, but SSL is required") />
   <#return false />
 </#if>
 
 <#if !allowExternal >
   <#if !(http.request.referrer)?? || !(http.request.referrer?has_content) >
     <#local warningResult = logWarning("Request from external is not allowed, and referrer is null") />
     <#return false />
   </#if>
 
   <#if (http.request.serverName != parseHostname(http.request.referrer)) >
     <#local warningResult = logWarning("Request from external is not allowed: ${(http.request.referrer)!''}") />
     <#return false />
   </#if>
 </#if>
 
 <#return true />
</#function>
 
<#function logWarning warnMessage="">
 <#local requestUrl = (http.request.url)!"" />
 <#local requestIp = (http.request.remoteAddr)!"" />
 
 <#local warnOutput =                "warnMessage[" + warnMessage + "] " />
 <#local warnOutput = warnOutput +   "requestUrl[" + requestUrl + "] " />
 <#local warnOutput = warnOutput +   "userId[" + user.id + "] " />
 <#local warnOutput = warnOutput +   "userIp[" + requestIp + "] " />
 
 ${utils.logs.name.common_endpoint_utils.warn(warnOutput)}
 <#return true />
</#function>
 
<#function parseHostname url>
 <#local urlWithoutProtocol = url?replace("^((http[s]?):\\/)?\\/?","","r") />
 <#local urlParts = urlWithoutProtocol?split("/")>
 <#if urlParts?size gt 0>
     <#return urlParts[0] />
 </#if>
 <#return "" />
</#function>
 
<#function abbrevAmount amount>
 <#local output = amount?number />
 <#if output gt 99 && output lt 10000>
   <#local output = output?string(",###") />
 <#elseif output gt 10000 && output lt 100000>
   <#local output = (output/1000)?string("#.#") + "K" />
 <#elseif output gt 100000 && output lt 1000000>
   <#local output = (output/1000)?floor + "K" />
 <#elseif output gt 1000000>
   <#local output = (output/1000000)?string("#.#") + "M" />
 </#if>
 <#return output />
</#function>
 
<#-- function: indexOf
 Returns the nth index of a string match.
 param: string - The string to be searched
 param: match - The string to be matched
 param: matchNum - The number of instances of "match" to match.
 return: the value of the index of the nth (matchNum) match of "match" in "string".
 usage: ${indexOf(string," ", wordCount)}
-->
<#function indexOf string match matchNum>
 <#local index = -1 />
 <#list 1..matchNum as matchesCount>
   <#local newIndex = string?index_of(match,index+1) />
   <#local index = newIndex />
   <#if index gt 0>
     <#if matchesCount gte matchNum>
       <#break>
     </#if>
   <#else>
     <#break>
   </#if>
 </#list>
 <#return index>
</#function>
 
 
<#-- function: truncateWords
 Returns a string truncated after "wordCount" words, with the "truncationFragment" appended. For the purposes of
   this function, it is assumed that each space character corresponds to a word. All other whitespace is ignored.
 param: string - The string to be truncated
 param: wordCount - The number of words to include in the truncated string.
 param: truncationFragment - The fragment to append to the end of the truncated string.
 return: the string truncated after "wordCount" words with "truncationFragment" appended.
 usage: ${truncateWords(myText,5,"...")}
-->
<#function truncateWords string wordCount truncationFragment>
 <#local index = indexOf(string, " ", wordCount) />
 <#if index lt 0>
   <#return string>
 <#else>
   <#return string?substring(0,index) + truncationFragment>
 </#if>
</#function>
 
 
<#function replaceEntities str>
 <#local output = utils.html.stripper.from.owasp.strip(str) />
 <#local output = output?replace("&amp;", "&")?replace("&#39;", "'")?replace("&nbsp;", " ")?replace("&quot;", "\"") />
 <#return output />
</#function>