<#import "theme-lib.common-functions.ftl" as commonUtils />
<#import "theme-lib.utility-macros.ftl" as utilities />
<#include "theme-lib.hermes-variables.ftl" />
 
<#-- render message tile in community activity -->
<#macro printMsg msg index count showBoard=false sumThreadKudosCount="false">
 <#assign solved = "" />
 <#assign unread = "" />
 <#assign styleClass = "" />
 <#assign titleClass = "" />
 <#if msg.conversation.solved>
     <#assign solved = "custom-thread-solved" />
 </#if>
 <#if !msg.user_context.read>
     <#assign unread = "custom-thread-unread" />
 </#if>
 <#switch msg.conversation.style>
  <#case "forum">
     <#assign styleClass = "custom-style-forum" />
     <#assign titleClass = "forum" />
     <#break>
  <#case "tkb">
     <#assign styleClass = "custom-style-tkb" />
     <#assign titleClass = "tkb" />
     <#break>
  <#case "blog">
     <#assign styleClass = "lia-fa-blog custom-style-blog" />
     <#assign titleClass = "blog" />
     <#break>
  <#case "occasion">
     <#assign styleClass = "custom-style-occasion" />
     <#assign titleClass = "occasion" />
     <#break>
  <#default>
     <#assign styleClass = "" />
     <#assign titleClass = "" />
</#switch>
 <#-- custom message tile -->
 <article class="custom-message-tile ${solved} ${unread} ${msg.id}">
     <div>
         <h3>
             <#if msg.conversation.solved>
                 <i class="${solved}"><small>${text.format('theme-lib.general.thread-solved')}!</small></i>
             </#if>
             <a href="${msg.view_href}" title="${msg.subject}">${msg.subject}</a>
             <span class="${styleClass}" title="${titleClass}"></span>
         </h3>
         <p>
             <#assign strippedBody = msg.body?replace("<span class=\"lia-unicode-emoji\" title=\":[a-z_]+:\">(.*?)</span>", "", "r") />
             <#assign tmpBody = utilities.liRemoveHTML(strippedBody) />         
             <#assign bodyText = commonUtils.dataSanitizer(tmpBody, false) />
             <#noautoesc>${utils.html.truncate(globalMessageCharLimit, bodyText, '...')}</#noautoesc>
            <section>
                <button class="like-btn" data-msg-index="${msg.id}">Like</button>
                <button class="comment-btn" data-msg-index="${msg}">
                 <a href="${msg.view_href}">Comment</a>
                </button>
            </section>
          </p>
         <@utilities.messageImages msg.id/>
     </div>
     <aside>
         <@utilities.renderPostTime msg />&vert;
         <@utilities.messageCategoryInfo (msg)!"" />
     </aside>
     <footer>
         <@utilities.renderAuthorInfo msg />
         <@utilities.messageStatistics msg sumThreadKudosCount/>
     </footer>
 </article>
 <#--/custom message tile -->
</#macro>
<#--/render message tile in community activity -->
 
<#-- lazy load messages -->
<#function getLazyLoadMessages nodeId label messageListType pageSize scope offset allowedInteractionStyles="", isFeaturePost="false">
<#--label filter code  -->

<#if label?? && label?has_content >
   <#assign selectFields = "SELECT id, tags, labels, conversation.style, conversation.solved, conversation.last_post_time, conversation.last_post_time_friendly, user_context.read, images, board.id, board.title, board.view_href, teaser, body, post_time_friendly, subject,author, author.login,author.id, author.view_href, author.avatar.profile, author.rank.name, author.rank.color, author.rank.bold, post_time, view_href, kudos.sum(weight), replies.count(*), metrics.views, conversation.solved, conversation.featured FROM messages WHERE depth = 0 AND category.id = '${nodeId}' AND labels.text='${label}' " />
<#else>
   <#local selectFields = "id, tags, labels, conversation.style, conversation.solved, conversation.last_post_time, conversation.last_post_time_friendly, user_context.read, images, board.id, board.title, board.view_href, teaser, body, post_time_friendly, subject,author, author.login,author.id, author.view_href, author.avatar.profile, author.rank.name, author.rank.color, author.rank.bold, post_time, view_href, kudos.sum(weight), replies.count(*), metrics.views, conversation.solved, conversation.featured" />
</#if>
<#--label filter code  -->

 <#local conversationClause = messageUtils.getConversationClause(allowedInteractionStyles) />
 <#local where = " WHERE depth=0 " +  conversationClause />
 <#assign feature_where = "WHERE conversation.featured = true AND depth = 0" />

<#if scope?string == "category">
    <#if feature_where?contains("conversation.featured = true")> 
        <#local msgQry = "SELECT ${selectFields} FROM messages ${feature_where} ${orderClause}" />
    <#else> 
        <#local where = where + " AND category.id='${nodeId}' " />
        <#local orderLastPost = (restadmin("/categories/id/${nodeId}/settings/name/layout.sort_view_by_last_post_date").value)!"false" />
    </#if>
<#elseif scope?string == "board">
    <#local where = where + " AND board.id='${nodeId}' " />
    <#local orderLastPost = (restadmin("/boards/id/${nodeId}/settings/name/layout.sort_view_by_last_post_date").value)!"false" />
<#else>
    <#local orderLastPost = settings.name.get("layout.sort_view_by_last_post_date", "false") />
</#if>

 <#--  <#assign feature_where = "WHERE conversation.featured = true AND depth = 0">
 <#if scope?string == "category">
    <#if feature_where?contains("conversation.featured = true")> 
            <#local msgQry = "SELECT ${selectFields} FROM messages ${feature_where} ${orderClause}" />
        <#else> 
        <#local where = where + " AND category.id='${nodeId}' " />
        <#local orderLastPost = (restadmin("/categories/id/${nodeId}/settings/name/layout.sort_view_by_last_post_date").value)!"false" />
    </#if> 
 <#elseif scope?string == "board">
     <#local where = where + " AND board.id='${nodeId}' " />
     <#local orderLastPost = (restadmin("/boards/id/${nodeId}/settings/name/layout.sort_view_by_last_post_date").value)!"false" />
 <#else>
     <#local orderLastPost = settings.name.get("layout.sort_view_by_last_post_date", "false") />
 </#if>  -->
 
 <#if messageListType?string == 'recent'>
   <#if orderLastPost == "true">
       <#local orderClause = " ORDER BY conversation.last_post_time DESC LIMIT " + pageSize + " offset " + offset/>
   <#else>
       <#local orderClause = " ORDER BY post_time DESC LIMIT " + pageSize + " offset " + offset />
   </#if>
 <#elseif messageListType?string == "topkudos">
     <#local orderClause = " ORDER BY kudos.sum(weight) DESC LIMIT " + pageSize + " offset " + offset />
 <#elseif messageListType?string == "views">
     <#local orderClause = " ORDER BY metrics.views DESC LIMIT " + pageSize + " offset " + offset />
 <#elseif messageListType?string == "replies">
     <#local orderClause = " ORDER BY replies.count(*)  DESC LIMIT " + pageSize + " offset " + offset />
 <#elseif messageListType?string == "feature">
        <#local orderClause = " ORDER BY conversation.featured ASC LIMIT " + pageSize + " offset " + offset />
 <#else>
     <#local orderClause = "" />
 </#if>
 
<#--  <#assign feature_where = "WHERE conversation.featured = true AND depth = 0">
<#if feature_where?contains("conversation.featured = true")> 
        <#local msgQry = "SELECT ${selectFields} FROM messages ${feature_where} ${orderClause}" />
    <#else> 
        <#local msgQry = "SELECT ${selectFields} FROM messages ${where} ${orderClause}" />
</#if>  -->

 <#--  <#local msgQry = "SELECT ${selectFields} FROM messages ${where} ${orderClause}" />  -->
 <#if scope?string == "category">
    <#--  <#if label?? && label?has_content>  -->
        <#local msgQry = "${selectFields} ${orderClause}" />
        <#--  ${utils.externalLogs.name.categoryquery.info("Query :${msgQry}")}  -->
    <#--  </#if>  -->
 <#else>
     <#local msgQry = "SELECT ${selectFields} FROM messages ${where} ${orderClause}" />
 </#if>
 <#local msgRes = commonUtils.executeLiQLQuery(msgQry) />
 <#return msgRes />
</#function>
<#--/lazy load messages -->
 
<#-- get message count -->
<#function getMessagesCount nodeId, label, messageListType, scope, allowedInteractionStyles="", isFeaturePost="false">
<#local conversationClause = getConversationClause(allowedInteractionStyles) />
<#local where = " WHERE depth=0 " + conversationClause />
<#if scope?string == "category">
   <#local where = where + " AND category.id='${nodeId}' " />
<#elseif scope?string == "board">
   <#local where = where + " AND board.id='${nodeId}' " />
</#if>

<#if isFeaturePost == "true">
        <#local where = where + " AND conversation.featured = true" />
</#if>
<#-- label filter code  -->
<#if label??&&label?has_content>
    <#local qry = "SELECT count(*) FROM messages ${where} AND labels.text='${label}' " />
<#else>
    <#local qry = "SELECT count(*) FROM messages ${where}" />
</#if>
<#--label filter code  -->

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