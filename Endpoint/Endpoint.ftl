<#assign authorId = http.request.parameters.name.get("id","") />

<#assign query = "select * from messages where author.id = '" + authorId + "'" />

<#assign result = rest("2.0", "/search?q=" + query?url) />

<@compress>
{
    <#if result.status == "success">
        "result": "success",
        <#assign allData = result.data.items />

        "messages": [
        <#list allData as message>
            {
                "id": ${message.id},
                "board_id": ${message.board.id},
                "subject": ${message.subject},
                "href": ${message.href},
                "view_href": ${message.view_href},
            }<#if message_has_next>,</#if>
        </#list>
        ]
    <#else>
        "result": "error"
    </#if>
}
</@compress>

