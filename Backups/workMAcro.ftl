<#import "theme-lib.common-functions.ftl" as commonUtils />
<#import "theme-lib.utility-macros.ftl" as utilities />
<#include "theme-lib.hermes-variables.ftl" />
 
<#-- render message tile in community activity -->
<#macro printMsg msg index count showBoard=false sumThreadKudosCount="false">
 <#assign solved = "" />
 <#assign unread = "" />
 <#if msg.conversation.solved>
     <#assign solved = "custom-thread-solved" />
 </#if>
 <#if !msg.user_context.read>
     <#assign unread = "custom-thread-unread" />
 </#if>
 <#-- custom message tile -->
 <article class="custom-message-tile ${solved} ${unread}">
    <aside>
      <@utilities.renderAuthorInfo msg />
    </aside>
     <div>
         <h3>
             <#if msg.conversation.solved>
                 <i class="${solved}"><small>${text.format('theme-lib.general.thread-solved')}!</small></i>
             </#if>
             <a href="${msg.view_href}" title="${msg.subject}">${msg.subject}</a>
         </h3>
         <p>
             <#assign strippedBody = msg.body?replace("<span class=\"lia-unicode-emoji\" title=\":[a-z_]+:\">(.*?)</span>", "", "r") />
             <#assign tmpBody = utilities.liRemoveHTML(strippedBody) />         
             <#assign bodyText = commonUtils.dataSanitizer(tmpBody, false) />
             <#noautoesc>${utils.html.truncate(globalMessageCharLimit, bodyText, '...')}</#noautoesc>
         </p>
         <@utilities.messageImages msg.id/>
     </div>
     <#--  <aside>
         <@utilities.renderPostTime msg />&vert;
         <@utilities.messageCategoryInfo (msg)!"" />
     </aside>  -->
     <footer>
        <aside>
         <@utilities.renderPostTime msg /><small>${text.format('general.in')}</small>
         <@utilities.messageCategoryInfo (msg)!"" />
        </aside>
         <#--  <@utilities.renderAuthorInfo msg />  -->
         <@utilities.messageStatistics msg sumThreadKudosCount/>
     </footer>
 </article>
 <#--/custom message tile -->
</#macro>
<#--/render message tile in community activity -->
 
<#-- lazy load messages -->
<#--  This code is changed as part of devlopement https://italent.atlassian.net/browse/TOAST-4 -->
<#function getLazyLoadMessages nodeId messageListType pageSize scope offset allowedInteractionStyles="">
 <#local selectFields = "id, tags, labels, conversation.solved, conversation.last_post_time, conversation.last_post_time_friendly, user_context.read, images, board.id, board.title, board.view_href, teaser, body, post_time_friendly, subject, author.login, author.view_href, author.avatar.profile, author.rank.name, author.rank.color, author.rank.bold, post_time, view_href, kudos.sum(weight), replies.count(*), metrics.views, conversation.solved, conversation.featured" />
 
 <#local conversationClause = messageUtils.getConversationClause(allowedInteractionStyles) />
 <#local where = " WHERE depth=0 " +  conversationClause />
 
 <#if scope == "category">
     <#local where = where + " AND category.id='${nodeId}' " />
     <#local orderLastPost = (restadmin("/categories/id/${nodeId}/settings/name/layout.sort_view_by_last_post_date").value)!"false" />
 <#elseif scope == "board">
     <#local where = where + " AND board.id='${nodeId}' " />
     <#local orderLastPost = (restadmin("/boards/id/${nodeId}/settings/name/layout.sort_view_by_last_post_date").value)!"false" />
 <#else>
     <#local orderLastPost = settings.name.get("layout.sort_view_by_last_post_date", "false") />
 </#if>
 
 <#if messageListType == 'recent'>
   <#if orderLastPost == "true">
       <#local orderClause = " ORDER BY conversation.last_post_time DESC LIMIT " + pageSize + " offset " + offset/>
   <#else>
       <#local orderClause = " ORDER BY post_time DESC LIMIT " + pageSize + " offset " + offset />
   </#if>
 <#elseif messageListType == "topkudos">
     <#local orderClause = " ORDER BY kudos.sum(weight) DESC LIMIT " + pageSize + " offset " + offset />
 <#elseif messageListType == "views">
     <#local orderClause = " ORDER BY metrics.views DESC LIMIT " + pageSize + " offset " + offset />
 <#elseif messageListType == "replies">
     <#local orderClause = " ORDER BY replies.count(*)  DESC LIMIT " + pageSize + " offset " + offset />
 <#elseif messageListType == "feature">
        <#local where = where + " AND conversation.featured = true " />
        <#local orderClause = " ORDER BY post_time DESC LIMIT " + pageSize + " offset " + offset />
 <#else>
     <#local orderClause = "" />
 </#if>
 
 <#local msgQry = "SELECT ${selectFields} FROM messages ${where} ${orderClause}" />
 <#local msgRes = commonUtils.executeLiQLQuery(msgQry) />
 <#return msgRes />
</#function>
<#--/lazy load messages -->
 
<#-- get message count -->
<#function getMessagesCount nodeId, label ,  messageListType, scope, allowedInteractionStyles="">
<#local conversationClause = getConversationClause(allowedInteractionStyles) />
<#local where = " WHERE depth=0 " + conversationClause />
<#if scope == "category">
   <#local where = where + " AND category.id='${nodeId}' " />
<#elseif scope == "board">
   <#local where = where + " AND board.id='${nodeId}' " />
</#if>
<#local qry = "SELECT count(*) FROM messages ${where}" />
<#return commonUtils.executeLiQLQuery(qry, true) />
</#function>
<#--/get message count -->
 
<#-- get interaction styles -->
<#function getConversationClause allowedInteractionStyles>
 <#local conversationClause = "" />
 <#if (allowedInteractionStyles == "" || allowedInteractionStyles == "none")>
     <#local allowedInteractionStyles = "forum,group,idea,qanda,review,tkb" />        
 </#if>
 <#if allowedInteractionStyles?has_content>
     <#list allowedInteractionStyles?split(',') as styleVal>
         <#local conversationClause= conversationClause + "'${styleVal?trim}'" />
         <#sep><#local conversationClause= conversationClause + ', ' /></#sep>
     </#list>
     <#local conversationClause= " AND conversation.style IN (" + conversationClause + ") " />
 </#if>
 <#return conversationClause />
</#function>
<#--/get interaction styles -->