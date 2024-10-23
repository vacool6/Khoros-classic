<#import "theme-lib.common-functions.ftl" as commonUtils />
<#import "theme-lib.utility-macros.ftl" as utilities />
<#include "theme-lib.hermes-variables.ftl" />

<#-- render message tile in community activity -->
<#macro printMsg msg index count showBoard=false>
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
        <div>
                <h3>
                    <#if msg.conversation.solved>
                        <i class="${solved}"><small>${text.format('theme-lib.general.thread-solved')}!</small></i>
                    </#if>
                    <a href="${msg.view_href}" title="${msg.subject}">${msg.subject}</a>
                </h3>
            <p>
                <#assign tmpBody = utilities.liRemoveHTML(msg.body) />
                <#assign bodyText = commonUtils.dataSanitizer(tmpBody, true) />
        <#--  Start:This code is added as part of https://italent.atlassian.net/browse/ZOOM-5 -->
                <#assign bodyTextLength = bodyText?length>
                <#if (bodyTextLength > globalMessageCharLimit)>
                 <section class="less-content">
                    <#noautoesc>
                        ${utils.html.truncate(globalMessageCharLimit, bodyText, '... ')}<b class="show-more">Show more</b>
                    </#noautoesc>
                 </section>
                 <section class="more-content">
                    <#noautoesc>
                        ${msg.body}
                    </#noautoesc>
                    <br>
                    <b class="show-less" style="margin:1rem 0;">Show less</b>
                    <br>
                    <br>
                 </section>
                <#else>
                  <#noautoesc>
                     ${msg.body}
                  </#noautoesc>
                </#if>
            </p>
            <#--  <@utilities.messageImages msg.id/>  -->
        <#--  Ends: https://italent.atlassian.net/browse/ZOOM-5 -->
        </div>
        <aside>
            <@utilities.communityActivityfooter (msg)!"" />
            <#--  <@utilities.renderPostTime msg />  -->
            <@utilities.renderLatestReplyTime msg />
        </aside>
        <footer>
            <@utilities.renderAuthorInfo msg />
            <#--  <@utilities.messageStatistics msg/>  -->
        </footer>
    </article>
    <#--/custom message tile -->
</#macro>
<#--/render message tile in community activity -->

<#-- lazy load messages -->
<#function getLazyLoadMessages nodeId messageListType pageSize scope offset >
    <#local selectFields = "id, tags, labels, conversation.solved, conversation.last_post_time, conversation.last_post_time_friendly, user_context.read, images, board.id, board.title, board.view_href, teaser, body, post_time_friendly, subject, author.login, author.view_href, author.avatar.profile, author.rank.name, author.rank.color, author.rank.bold, post_time, view_href, kudos.sum(weight), replies.count(*), metrics.views" />

    <#local where = " WHERE depth=0 AND conversation.style='forum' " />

    <#if scope == "category">
        <#local where = where + " AND category.id='${nodeId}' " />
    <#elseif scope == "board">
        <#local where = where + " AND board.id='${nodeId}' " />
    </#if>

    <#if messageListType == 'recent'>
        <#local orderClause = " ORDER BY conversation.last_post_time DESC LIMIT " + pageSize + " offset " + offset />
    <#elseif messageListType == 'views'>
        <#local orderClause = " ORDER BY metrics.views DESC LIMIT " + pageSize + " offset " + offset />
    <#elseif messageListType == 'solved'>
        <#local where = where + " AND conversation.solved=true " />
        <#local orderClause = " ORDER BY post_time DESC LIMIT " + pageSize + " offset " + offset />
    <#elseif messageListType == 'unanswered'>
        <#local where = where + " AND replies.count(*)=0 " />
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
<#function getMessagesCount nodeId, messageListType, scope>
    <#local where = " WHERE depth=0 AND conversation.style='forum'" />
    <#if scope == "category">
        <#local where = where + " AND category.id='${nodeId}' " />
    <#elseif scope == "board">
        <#local where = where + " AND board.id='${nodeId}' " />
    </#if>
    <#if messageListType == 'solved'>
        <#local where = where + " AND conversation.solved=true " />
    <#elseif messageListType == 'unanswered'>
        <#local where = where + " AND replies.count(*)=0 " />
    </#if>

    <#local qry = "SELECT count(*) FROM messages ${where}" />
    <#return commonUtils.executeLiQLQuery(qry, true) />
</#function>
<#--/get message count -->