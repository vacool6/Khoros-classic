<style>
 .disabled-icons {
    pointer-events:none; 
    opacity:0.6;  
  }

  .show-more,
  .show-less {
    color: #007bff;
    cursor:pointer;
  }

  .show-more:hover,
  .show-less:hover {
    text-decoration: underline;
  }

  .more-content{
    display:none;
  }
</style>
<#-- custom message list -->
<#import "Zoom-theme-lib.common-functions.ftl" as commonUtils />
<#import "theme-lib.utility-macros.ftl" as utilities />
<#include "theme-lib.hermes-variables.ftl" />

<#assign showPaging = "true" />
<#assign sorting = http.request.parameters.name.get("sort", "") />

<#-- page size -->
<#assign pageSize = coreNode.settings.name.get("layout.messages_per_page_linear", "10")?number />
<#if user.registered>
    <#assign pageSizeUser = settings.name.get("layout.messages_per_page_linear") />
    <#if pageSizeUser?number != pageSize?number>
        <#assign pageSize = pageSizeUser />
    </#if>
</#if>

<#if webuisupport.path.parameters.name.get("label-name")??>
    <#assign label = webuisupport.path.parameters.name.get("label-name").getText() />
    <#assign label_query = " AND labels.text='"+label+"' " />
    <#assign msg_label_query = "" />
<#else>
    <#assign label_query = "" />
    <#assign msg_label_query = "" />
</#if> 

<#-- grab paging param -->
<#assign pageNum = webuisupport.path.parameters.name.get("page", 1) />

<#assign offset = (pageNum - 1) * pageSize?number />

<#-- build base queries -->
<#assign baseQry = "SELECT id, subject, body, metrics.views, tags, labels, images, post_time, post_time_friendly, conversation.last_post_time, moderation_status, conversation.last_post_time_friendly, author.login, author.avatar.message, view_href, author.view_href, read_only, author.rank.name, author.rank.color, author.rank.icon_left, author.rank.bold, author.rank.icon_right, author.online_status,board.id, author.avatar.profile, board.view_href, board.title, replies.count(*), kudos.sum(weight), conversation.solved, user_context.read FROM messages WHERE depth = 0 AND board.id = '${coreNode.id}' " />
<#assign basePagingQry = "SELECT count(*) FROM messages WHERE depth = 0 AND board.id = '${coreNode.id}' " />
<#assign whereClause = label_query />

<#if !sorting?has_content>
    <#assign sorting = "recent" />
</#if>
<#switch sorting>
    <#case "solved">
        <#assign whereClause = whereClause + " AND conversation.solved=true " />
        <#assign orderClause = "ORDER BY post_time DESC " />
    <#break>
    <#case "views">
        <#assign orderClause = "ORDER BY metrics.views DESC " />
    <#break>
    <#case "unanswered">
        <#assign whereClause = whereClause + " AND replies.count(*)=0 " />
        <#assign orderClause = " ORDER BY post_time DESC " />
    <#break>
    <#default>
        <#assign orderClause = "ORDER BY conversation.last_post_time DESC " />
    <#break>
</#switch>

<#assign limitClause = "LIMIT ${pageSize} OFFSET ${offset}" />

<#-- fetch recent topics by location filter -->
<#assign qry = baseQry + whereClause + orderClause + limitClause />
<#assign topics = commonUtils.executeLiQLQuery(qry) />

<#assign baseFloatQry = "SELECT message.id, message.tags, message.labels, message.metrics.views, message.images, message.subject, message.body, message.post_time, message.post_time_friendly, message.moderation_status, message.conversation.last_post_time, message.conversation.last_post_time_friendly, message.read_only, message.author.login, message.author.avatar.message, message.view_href, message.author.view_href, message.author.rank.name, message.author.rank.color, message.author.rank.icon_left, message.author.rank.bold, message.author.rank.icon_right, message.author.online_status,message.board.id, message.author.avatar.profile, message.board.view_href, message.board.title, message.replies.count(*), message.kudos.sum(weight), message.conversation.solved, message.user_context.read FROM floated_messages WHERE message.board.id = '${coreNode.id}'" />

<#assign baseUserQryScope = " AND scope = 'user' " />
<#-- get user scoped floated message -->
<#assign baseUserQry = baseFloatQry + baseUserQryScope + msg_label_query />
<#assign userFloatedTopics = commonUtils.executeLiQLQuery(baseUserQry) />

<#--<#assign baseGlobalQryScope = " AND scope = 'global' " />
<#-- get global scoped floated message
<#assign baseGlobalQry = baseFloatQry + baseGlobalQryScope  + msg_label_query/>
<#assign globalFloatedTopics = commonUtils.executeLiQLQuery(baseGlobalQry) /> -->

<div class="custom-message-list ${(coreNode.id == 'OnDemandLearning')?then('cs-ondemand-learning-message-list', '')}">
    <section>
        <header>
            <h2>${text.format("theme-lib.message-list.title")}</h2>
            <div>
                <label for="community-activity-sorted-by">${text.format("sortingbar.sortby")}</label>
                <select id="community-activity-sorted-by">
                    <option value="recent" <#if sorting == 'recent'>selected</#if>>${text.format("theme-lib.community-activity.recent")}</option>
                    <option value="views" <#if sorting == 'views'>selected</#if>>${text.format("theme-lib.community-activity.views")}</option>
                    <option value="solved" <#if sorting == 'solved'>selected</#if>>${text.format("theme-lib.community-activity.solved")}</option>
                    <option value="unanswered" <#if sorting == 'unanswered'>selected</#if>>${text.format("theme-lib.community-activity.unanswered")}</option>
                </select>
                <@component id="theme-lib.start-conversation-button" />
            </div>
        </header>
        <div class="links-wrapper">
            <span class="tablinks <#if sorting == "recent">active</#if>" data-value="recent">${text.format("theme-lib.community-activity.recent")}</span>
            <span class="tablinks <#if sorting == "views">active</#if>" data-value="views">${text.format("theme-lib.community-activity.views")}</span>
            <span class="tablinks <#if sorting == "solved">active</#if>" data-value="solved">${text.format("theme-lib.community-activity.solved")}</span>
            <span class="tablinks <#if sorting == "unanswered">active</#if>" data-value="unanswered">${text.format("theme-lib.community-activity.unanswered")}</span>
        </div>

        <#assign isOdd = true />
        <#list userFloatedTopics as userFloatedTopic>
            <#if userFloatedTopic.message??>
                <@renderMessage userFloatedTopic.message false false false false true/>
            </#if>
        </#list>
      <#--  <#list globalFloatedTopics as globalFloatedTopic>
            <#if globalFloatedTopic.message??>
                <@renderMessage globalFloatedTopic.message false false false false true/>
            </#if>
        </#list> -->
        <#list topics as message>
            <@renderMessage message false message?is_odd_item />
        </#list>
        <#if topics?size == 0 && userFloatedTopics?size == 0 >
            <div class="no-messages">${text.format("theme-lib.community-activity.no-messages")}</div>
        </#if>
    </section>
</div>
<#-- pagination -->
<#if showPaging == "true">
    <#assign pagingQry = basePagingQry + whereClause />
    <#assign topicCnt = commonUtils.executeLiQLQuery(pagingQry, true) />
    <#assign pageableItem = webuisupport.paging.pageableItem.setCurrentPageNumber(pageNum).setItemsPerPage(pageSize?number).setTotalItems(topicCnt).setPagingMode("enumerated").build />
    <@component id="common.widget.pager" pageableItem=pageableItem />
</#if>
<#--/pagination -->

<@liaAddScript>
;(function ($) {
    $('#community-activity-sorted-by').change(function() {
        $('.tablinks[data-value="'+$(this).val()+'"]').addClass('active').siblings('.tablinks').removeClass('active');
        window.location = "${coreNode.webUi.url}?&sort="+$(this).val();
    });

<#--  Sameer mods  -->
function handleKudosAction(mesId, method, url) {
    if (mesId) {
        $.ajax({
            type: method,
            url: url + mesId + '/kudos',
            headers: {
                accept: 'application/json',
                'content-type': 'application/json'
            },
            data: method === 'POST' ? JSON.stringify({ data: { type: 'kudo' } }) : null,
            success: function(response) {
                console.log(response);
                window.location.reload();
            },
            error: function(err) {
                console.error(err);
            }
        });
    } else {
        console.error("Message ID is not defined for this button");
    }
}

function toggleContent(index, showMore) {
    $('.more-content').eq(index).toggle(showMore);
    $('.less-content').eq(index).toggle(!showMore);
    $('.show-more').eq(index).toggle(!showMore);
    $('.show-less').eq(index).toggle(showMore);
}

$(document).on('click', '.custom-tile-replies', function() {
    let href = $(this).attr('view-href');
    
    if (href) {
        window.open(href); 
    } else {
        console.error("href is not defined for this button");
    }
});

$(document).on('click', '.custom-tile-kudos, .custom-tile-kudos-liked', function() {
    let mesId = $(this).attr('msg-id');
    let method = $(this).hasClass('custom-tile-kudos') ? 'POST' : 'DELETE';
    let url = '/api/2.0/messages/';
    
    document.querySelectorAll('.custom-tile-kudos, .custom-tile-replies, .custom-tile-kudos-liked')
        .forEach(button => button.classList.add('disabled-icons'));

    handleKudosAction(mesId, method, url);
});

$(document).on('click', '.show-more', function() {
    toggleContent($('.show-more').index(this), true);
});

$(document).on('click', '.show-less', function() {
    toggleContent($('.show-less').index(this), false);
});

<#--  Sameer mod ends  -->

    $('.tablinks').click(function(evt) {
        evt.preventDefault();
        var listType=$(this).attr('data-value');
        $(this).addClass('active').siblings('.tablinks').removeClass('active');
        $('#community-activity-sorted-by').val(listType);
        window.location = "${coreNode.webUi.url}?&sort="+listType;
    });
})(LITHIUM.jQuery);
</@liaAddScript>
<#--/custom message list -->

<#-- render message tile in message list -->
<#macro renderMessage msg showBoard=true isOdd=false isFirst=false isLast=false isFloated=false>
    <#assign solved = "" />
    <#assign unread = "" />
    <#assign floated = "" />
    <#assign escalated = "" />
    <#assign locked = "" />
    <#assign msg_status_icon = "" />
    <#assign msg_status_txt = "" />
    <#if msg.read_only == true>
        <#assign locked = "custom-thread-locked" />
        <#assign msg_status_icon = "custom-thread-locked" />
        <#assign msg_status_txt = "theme-lib.general.thread-locked" />
    </#if>
    <#assign requires_moderation = "" />
    <#if msg.moderation_status == "unmoderated">
        <#assign requires_moderation = "custom-thread-requires-moderation" />
    </#if>
    <#if isFloated>
        <#assign floated = "custom-thread-floated" />
        <#assign msg_status_icon = "custom-thread-floated" />
        <#assign msg_status_txt = "theme-lib.general.thread-floated" />
    </#if>
    <#if msg.conversation.solved>
        <#assign solved = "custom-thread-solved" />
        <#assign msg_status_icon = "custom-thread-solved" />
        <#assign msg_status_txt = "theme-lib.general.thread-solved" />
    </#if>
    <#if !msg.user_context.read>
        <#assign unread = "custom-thread-unread" />
    </#if>
    <#-- custom message tile -->
    <article class="custom-message-tile ${escalated} ${locked} ${solved} ${floated} ${requires_moderation} ${unread}">
        <#-- batch processing -->
        <#local showBatchProcessingCheckBox = "false"/>
        <#if user.registered>
            <#local showBatchProcessingCheckBox = settings.name.get("layout.show_batch_checkboxes")/>
        </#if>
        <#if coreNode.permissions.hasPermission("manage_messages") && showBatchProcessingCheckBox?boolean>
            <#local messageInBoard = rest("/messages/id/${msg.id}/board_id").value/>
            <#local batchProcessingValue = "${messageInBoard}:${msg.board.id}"?url/>
            <input name="bm" type="checkbox" value="${batchProcessingValue}" title="Select ${msg.subject!''}" class="BatchProcessing" />
        </#if>
        <#--/batch processing -->
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
                <#-- At this point, we should be scrubbed enough that we can disable autoesc so we don't escape basic char encoding (eg: &nbsp;) -->
                <#--  Sameer mods  -->
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
                    <b class="show-less">Show less</b>
                 </section>
                <#else>
                  <#noautoesc>
                     ${msg.body}
                  </#noautoesc>
                </#if>             
            </p>
            <#--  <@utilities.messageImages msg.id/>  -->
            <#--  Sameer mods ends  -->
        </div>
        <aside>
            <@utilities.renderPostTime msg />&vert;
            <@utilities.messageCategoryInfo (msg)!"" />
            <@utilities.renderLatestReplyTime msg />

            <div>
                <#if isFloated>
                    <i class="custom-thread-floated">${text.format("theme-lib.general.thread-floated")}</i>
                <#elseif msg.read_only == true>
                    <i class="custom-thread-locked">${text.format("theme-lib.general.thread-locked")}</i>
                 </#if>
            </div>
        </aside>
        <footer>
            <@utilities.renderAuthorInfo msg />
            <@utilities.messageStatistics msg/>
        </footer>
    </article>
    <#--/custom message tile -->
</#macro>
<#--/render message tile in message list -->