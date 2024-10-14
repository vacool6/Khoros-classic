<#--  "custom.target_communities_dev_topics" is the SLE  -->

  
  <style>
        .hover-card {
            border: 1px solid black;
            margin: 20px 0;
            padding: 15px;
            transition: transform 0.3s ease, background-color 0.3s ease;
        }

        .hover-card:hover {
            transform: scale(0.9);
            background-color: #f0f0f0; 
            }
    </style>

<#assign offsetcount = http.request.parameters.name.get("offsetcount","0")/>
<#assign code=settings.name.get("custom.target_communities_dev_topics")>
 
<#assign user = restadmin("2.0","/search?q="+"select * FROM messages WHERE category.id = 'iTalent_POC' limit ${code} offset ${offsetcount}"?url)/>
<#list user.data.items as message>

<#assign kudo = restadmin("2.0","/search?q="+"SELECT * FROM kudos WHERE message.id ='${message.id}'"?url).data.size/>
<#assign reply = restadmin("2.0","/search?q="+"SELECT * FROM messages WHERE parent.id = '${message.id}'"?url).data.size/>

<div class="hover-card">
<div><b>Subject:</b> ${message.subject}</div>
<div><b>Id:</b> ${message.id}</div>
<div><b>Kudos:</b>${kudo}</div>
<div><b>Replies:</b>${reply}</div>
<div><b>Views:</b>${message.metrics.views}</div>
</div>
</#list>