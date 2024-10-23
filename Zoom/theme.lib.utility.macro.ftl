<#include "theme-lib.hermes-variables.ftl" />
<#--  Added by iTalent as part of https://italent.atlassian.net/browse/ZOOM-4  -->
<#macro messageCategoryInfoo msg>    
    <#local userData  = (msg.author)!'' />
    <#local username = (userData.login)!'' />
    <div class="recent-activity-footer">
        <div class="msg-auther-info">
                <strong>
                    <#--  <span>${text.format("general.by")} </span>  -->
                    <a class="lia-link-navigation lia-page-link lia-user-name-link" target="_self" href="${(userData.view_href)!''}" rel="author" title="${text.format('theme-lib.general.view-profile')}">
                        <span class="<#if (userData.rank.bold)!false>login-bold</#if>" <#if (userData.rank.color)?has_content>style="color:#${(userData.rank.color)!''}"</#if>>${username}</span>
                    </a>
                </strong>
                <small>&bull;</small> <em>${(userData.rank.name)!''}</em>
            
        </div>
        <div class="custom-tile-category">
            <strong>
                <span>${text.format('theme-lib.general.posted-in')} </span>
                <a href="${msg.board.view_href}">${msg.board.title}</a>
            </strong>
        </div>
        <div class="custom-user-statistics">
            <ul class="custom-tile-statistics">
                <li class="custom-tile-views"><b>${msg.metrics.views}</b> ${text.format("general.Views")}</li>
                <li class="custom-tile-replies"><b>${msg.replies.count}</b> ${text.format("general.replies")}</li>
                <li class="custom-tile-kudos"><b>${msg.kudos.sum.weight}</b> ${text.format("general.kudos")}</li>
            </ul>
        </div>
        <div class="custom-tile-date">
            <#if msg.post_time_friendly?has_content>
                <time>${msg.post_time_friendly}</time>
            <#else>
                <span>${text.format("general.on")} </span><time>${msg.post_time?string(globalDateTimeFormat)}</time>
            </#if>
        </div>
    </div>
</#macro>

<#macro renderAuthorAvathar msg>
    <#local userData  = (msg.author)!'' />
    <#local username = (userData.login)!'' />
    
    <div class="custom-tile-author-info">
        <a class="UserAvatar lia-link-navigation" href="${(userData.view_href)!''}" title="${text.format('theme-lib.general.view-profile')}">
            <img class="lia-user-avatar-message" alt="${username}" src="${(userData.avatar.profile)!''}" />
        </a>
    </div>
</#macro>

<#--  End of https://italent.atlassian.net/browse/ZOOM-4  -->

<#-- render author info in message tile -->
<#macro renderAuthorInfo msg>
    <#local userData  = (msg.author)!'' />
    <#local username = (userData.login)!'' />
    
    <div class="custom-tile-author-info">
        <a class="UserAvatar lia-link-navigation" href="${(userData.view_href)!''}" title="${text.format('theme-lib.general.view-profile')}">
            <img class="lia-user-avatar-message" alt="${username}" src="${(userData.avatar.profile)!''}" />
        </a>
        <strong>
            <span>${text.format("general.by")} </span>
            <a class="lia-link-navigation lia-page-link lia-user-name-link" target="_self" href="${(userData.view_href)!''}" rel="author" title="${text.format('theme-lib.general.view-profile')}">
                <span class="<#if (userData.rank.bold)!false>login-bold</#if>" <#if (userData.rank.color)?has_content>style="color:#${(userData.rank.color)!''}"</#if>>${username}</span>
            </a>
        </strong>
        <small>&bull;</small> <em>${(userData.rank.name)!''}</em>
    </div>
</#macro>
<#--/render author info in message tile -->

<#-- render post time in message tile -->
<#macro renderPostTime msg>
    <div class="custom-tile-date">
        <#if msg.post_time_friendly?has_content>
            <time>${msg.post_time_friendly}</time>
        <#else>
            <span>${text.format("general.on")} </span><time>${msg.post_time?string(globalDateTimeFormat)}</time>
        </#if>
    </div>
</#macro>
<#--/render post time in message tile  -->

<#-- render category info in message tile -->
<#macro messageCategoryInfo msg>
    <div class="custom-tile-category">
        <strong>
            <span>${text.format('theme-lib.general.posted-in')} </span>
            <a href="${msg.board.view_href}">${msg.board.title}</a>
        </strong>
    </div>
</#macro>
<#--/render category info in message tile -->

<#macro renderLatestReplyTime msg>
    <#if (msg.replies.count > 0) >
        <#assign latestMsgId = restadmin('/threads/id/${msg.id}/messages/latest').message.id />
        <#assign latestReplyQry = "SELECT view_href FROM messages WHERE id='${latestMsgId}'" />
        <#assign latestReply = commonUtils.executeLiQLQuery(latestReplyQry) />
        <div class="custom-latest-reply-date">
            <strong>
                <span>${text.format('theme-lib.general.latest-reply')} </span>
                <a href="${latestReply[0].view_href}">
                    <#if msg.conversation.last_post_time_friendly?has_content>
                        <time>${msg.conversation.last_post_time_friendly}</time>
                    <#else>
                        <time>${msg.conversation.last_post_time?string(globalDateTimeFormat)}</time>
                    </#if>
                </a>
            </strong>
        </div>
    </#if>
</#macro>

<#-- render image in message tile -->
<#function renderMessageImg msg showVideo=true>
    <#assign postImg = asset.get("/html/assets/img_tile-default.png") />
    <#assign videoImg = '' />
    <#-- check for video image-->
    <#if showVideo>
      <#assign videoQry = "select thumb_href from videos where messages.id='${msg.id}'" />
      <#assign videoRes = commonUtils.executeLiQLQuery(videoQry) />
      <#if videoRes?size gt 0>
        <#assign videoImg = videoRes[0].thumb_href />
        <#assign postImg = videoImg />
      </#if>
    </#if>
    <#if msg.cover_image??>
        <#assign postImg = msg.cover_image.large_href />
    <#elseif videoImg == ''>
        <#if msg.images?? && msg.images.query??>
            <#-- check for teaser image -->
            <#assign imageQuery = msg.images.query + " AND association_type='teaser' LIMIT 1" />
            <#assign qry = commonUtils.executeLiQLQuery(imageQuery) />
            <#if qry?size gt 0 && (qry[0].large_href)?? >
                <#assign postImg = qry[0].large_href />
            <#else>
                <#assign imageQuery = msg.images.query + " AND association_type='body' LIMIT 1" />
                <#assign qry = commonUtils.executeLiQLQuery(imageQuery) />
                <#if qry?size gt 0  && (qry[0].large_href)?? >
                    <#assign postImg = qry[0].large_href />
                <#else>
                    <#assign postImg = postImg />
                </#if>
            </#if>
        </#if>
    </#if>
    <#return postImg />
</#function>
<#--/render image in message tile -->

<#-- render images from body in message tile -->
<#macro messageImages msgId>
    <#assign image_qry = "SELECT medium_href,title from images where messages.id = '${msgId}' limit 4" />
    <#assign images_result = commonUtils.executeLiQLQuery(image_qry) />
    <#if images_result?size gt 0>
        <figure>
            <#list images_result as image>
                <img src="${image.medium_href}" alt="${image.title}" />
            </#list>
        </figure>
    </#if>
</#macro>
<#--/render images from body in message tile -->

<#-- render statistics in message tile -->
<#macro messageStatistics msg> 
    <ul class="custom-tile-statistics">
        <li class="custom-tile-views"><b>${msg.metrics.views}</b> ${text.format("general.Views")}</li>
        <li class="custom-tile-replies"><b>${msg.replies.count}</b> ${text.format("general.replies")}</li>
        <li class="custom-tile-kudos"><b>${msg.kudos.sum.weight}</b> ${text.format("general.kudos")}</li>
    </ul>
</#macro>
<#--/render statistics in message tile -->

<#-- remove oyala script from message body -->
<#function liRemoveHTML body>
    <#local tempBody = '' />
    <#-- removes all script tag and removes all other HTML -->
    <#if body?has_content>
        <#local tempBody = body?replace('<script.*?>.*?<\\/script>', '', 'r')?replace('<a.*?\\sclass=.video-embed-link.*?>.*?<\\/a>', '', 'r') />
        <#local tempBody = utils.html.stripper.from.gdata.strip(tempBody) />
    </#if>
    <#return tempBody />
</#function>
<#--/remove oyala script from message body -->