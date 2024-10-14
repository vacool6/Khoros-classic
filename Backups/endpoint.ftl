<#import "theme-lib.common-functions.ftl" as commonUtils />
<#import "theme-lib.community-activity-macros.ftl" as messageUtils />

<#outputformat "JSON">
<@compress single_line=true>
<#assign status = STATUS_ERROR />
<#-- if the endpoint successfully completes its tasks, return with code STATUS_SUCCESS. -->
<#assign htmlPayload = "" />
<#assign message = "" />
<#assign messagesCount = "0" />
<#assign messageListType = "recent" />
<#assign eor = "false" /> <#-- end of results. -->

<#attempt>
    <#assign nodeId = commonUtils.getRequestField("node", "community")?js_string />
    <#assign messageListType = commonUtils.getRequestField("messageListType", "recent") />
    <#assign currentPage = commonUtils.getRequestField("currentPage", "0", true)?number />
    <#assign scope = commonUtils.getRequestField("scope", "all") />
    <#assign allowedInteractionStyles = commonUtils.getRequestField("allowedInteractionStyles", "") />
    
    <#-- persist the latest paging configuration in the user's cache. -->
    <#assign loadMoreData = {"messageListType": "${messageListType}", "currentPage": "${currentPage}"} />
    <#assign ret = http.session.setAttribute("${nodeId}Loader", utils.json.toJson(loadMoreData)) />
    <#attempt>
        <#assign ret = utils.json.fromJson(ret) />
    <#recover>
        <#assign ret = loadMoreData />
    </#attempt>

    <#if http.request.parameters.name.get("label")??>
        <#assign label = http.request.parameters.name.get("label") />
        <#assign scope = coreNode.nodeType />
        <#assign label_query = " AND labels.text='"+label+"' " />
        <#else>
        <#assign label = "" />
    </#if>

    <#assign pageSize = settings.name.get("layout.messages_per_page_linear", "5")?number />
    <#assign offset = currentPage * pageSize />
    
    <#assign messagesCount = messageUtils.getMessagesCount(nodeId, label, messageListType, scope, allowedInteractionStyles) />
    <#assign totalPages = (messagesCount/pageSize)?ceiling />
    
    <#if currentPage lt totalPages>
        <#assign messages = messageUtils.getLazyLoadMessages(nodeId, messageListType, pageSize, scope, offset, allowedInteractionStyles) />

        <#assign htmlPayload>
            <#-- NOTICE: Supply a message processing function to generate output. -->
            <#list messages as msg>
                <@messageUtils.printMsg msg msg?index messages?size /> 
            </#list>
        </#assign>
        <#if (currentPage + 1) == totalPages>
            <#assign eor = "true" />
        </#if>
    <#else>
        <#assign eor = "true" />
    </#if>
    <#assign status = STATUS_SUCCESS />
<#recover>
    <#assign message = .error?json_string />
</#attempt>
{
    "status":"${status}",
    "message":"${message}", 
    "messages":"${htmlPayload?json_string}",
    "EOR":"${eor}",
    "messagesCount":"${messagesCount}"
}
</@compress>
</#outputformat>