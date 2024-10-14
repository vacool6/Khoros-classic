  <#macro handleFilterOption selectedOption>

<#if selectedOption == "popular">
       <#assign Messages= rest("2.0","/search?q="+"select * from messages  where  category.id='iTalent_POC' and kudos.sum(weight)>0 ORDER BY kudos.sum(weight) DESC"?url).data.items![]/>
       <#assign Size = rest("2.0","/search?q="+"select count(*) from messages where  category.id='iTalent_POC' and kudos.sum(weight)>0 ORDER BY kudos.sum(weight) DESC"?url).data.count/>
    
<#elseif selectedOption == "all">
       <#-- display recent 5 posts -->
       <#assign Messages= rest("2.0","/search?q="+"select * from messages  where  category.id='iTalent_POC'"?url).data.items![]/>
       <#assign Size = rest("2.0","/search?q="+"select count(*) from messages where  category.id='iTalent_POC'"?url).data.count!0/>
    

  <#elseif selectedOption == "recent">
       <#-- display recent 5 posts -->
       <#assign Messages= rest("2.0","/search?q="+"select * from messages  where  category.id='iTalent_POC' and depth=0 ORDER BY conversation.last_post_time DESC LIMIT 5"?url).data.items![]/>
       <#assign Size = rest("2.0","/search?q="+"select count(*) from messages where  category.id='iTalent_POC' and depth=0 ORDER BY conversation.last_post_time DESC LIMIT 5"?url).data.count!0/>
       

  <#elseif selectedOption == "most-viewed">
       <#assign Messages= rest("2.0","/search?q="+"select * from messages where  category.id='iTalent_POC' ORDER BY metrics.views DESC limit 3"?url).data.items![]/>
       <#assign Size = rest("2.0","/search?q="+"select count(*) from messages where  category.id='iTalent_POC' ORDER BY metrics.views DESC limit 3"?url).data.count!0/> 
 	 
   </#if>
</#macro>
      
