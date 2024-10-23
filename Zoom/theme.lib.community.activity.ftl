<#-- custom community activity -->
<#import "theme-lib.common-functions.ftl" as commonUtils />
<#import "theme-lib.community-activity-macros.ftl" as messageUtils />

<@compress single_line=true>
    <#assign pageSize = 10 />
    <#assign scope = (env.context.component.getParameter('scope'))!"all" />
    <#assign loadMoreData = {"messageListType": "recent", "currentPage": "0"} />
    <#assign loadMoreObject = http.session.attributes.name.get("${coreNode.id}Loader", '${utils.json.toJson(loadMoreData)}') />
    <#attempt>
        <#assign loadMoreObject = utils.json.fromJson(loadMoreObject) />
    <#recover>
        <#assign loadMoreObject = loadMoreData />
    </#attempt>
    <#assign messageListType = loadMoreObject.messageListType!"recent" />
    <#assign currentPage = (loadMoreObject.currentPage!"0")?number />
    <#assign nodeId = coreNode.id />
    <#assign initialPayload = (currentPage + 1) * pageSize />
    <#assign offset = currentPage * pageSize />
    <#assign messagesCount = messageUtils.getMessagesCount(nodeId, messageListType, scope) />
    <#assign messages = messageUtils.getLazyLoadMessages(nodeId, messageListType, pageSize, scope, offset) />

    <#if messages?size gt -1>
        <div class="custom-community-activity" id="custom-loader">
            <section>
                <header>
                    <h2>${text.format("theme-lib.community-activity.title", coreNode.title)}</h2>
                    <div>
                        <label for="community-activity-sorted-by">${text.format("sortingbar.sortby")}</label>
                        <select id="community-activity-sorted-by">
                            <option value="recent" <#if messageListType == "recent">selected</#if>>${text.format("theme-lib.community-activity.recent")}</option>
                            <option value="views" <#if messageListType == "views">selected</#if>>${text.format("theme-lib.community-activity.views")}</option>
                            <option value="solved" <#if messageListType == "solved">selected</#if>>${text.format("theme-lib.community-activity.solved")}</option>
                            <option value="unanswered" <#if messageListType == "unanswered">selected</#if>>${text.format("theme-lib.community-activity.unanswered")}</option>
                        </select>
                        <@component id="theme-lib.start-conversation-button" />
                    </div>
                </header>
                <div class="links-wrapper">
                    <span class="tablinks <#if messageListType == "recent">active</#if>" data-value="recent">${text.format("theme-lib.community-activity.recent")}</span>
                    <span class="tablinks <#if messageListType == "views">active</#if>" data-value="views">${text.format("theme-lib.community-activity.views")}</span>
                    <span class="tablinks <#if messageListType == "solved">active</#if>" data-value="solved">${text.format("theme-lib.community-activity.solved")}</span>
                    <span class="tablinks <#if messageListType == "unanswered">active</#if>" data-value="unanswered">${text.format("theme-lib.community-activity.unanswered")}</span>
                </div>
                <section id="custom-loader-messages">
                    <div class="errors"></div>
                    <div class="message-list" data-attrib-current-page="${loadMoreObject.currentPage}" data-attrib-message-list-type="${loadMoreObject.messageListType}">
                        <#list messages as msg>
                            <@messageUtils.printMsg msg msg?index messages?size /> 
                        </#list> 
                    </div>
                    <div class="lia-view-all">
                        <a class="lia-link-navigation load-more-button <#if messagesCount lte pageSize>disabled</#if>" href="javascript:;" id="custom-loader-button">${text.format("pager.paging.type.view-more.text")}</a>
                    </div>                  
                </section>
            </section>
        </div>
        <@liaAddScript>
        ;(function($) {
            $(document).ready(function() {

                var getMessages = function (spinnerTarget, clearMessages) {
                    var parentComponent = $('#custom-loader');
                    var messageTarget = $('.message-list', parentComponent);
                    var currentPage = null;
                    try {
                        currentPage = parseInt($(messageTarget).attr('data-attrib-current-page'), 10);
                    } catch (e) {
                        currentPage = 0;
                    }
                    
                    $.ajax({
                        type: 'post',
                        url : '${commonUtils.getEndpointUrl("theme-lib.community-activity")}',
                        dataType: 'json',
                        data: {"currentPage": currentPage, "node": "${coreNode.id}", "scope":"${scope}", "messageListType": $(messageTarget).attr('data-attrib-message-list-type')},
                        context: parentComponent,
                        beforeSend: function(jqXHR, settings) {
                            <#-- add custom pre-request logic here -->
                            $('#custom-loader-messages .errors', parentComponent).empty();
                            $(spinnerTarget).prepend('<div class="spinner"></div>');
                        },
                        error: function (jqXHR, textStatus, errorThrown) {
                            $('#custom-loader-messages .errors', parentComponent).append(errorThrown);
                        },
                        success: function (data, textStatus, jqXHR) {
                            if (data.status == '${STATUS_SUCCESS}') {
                                if (clearMessages) {
                                    messageTarget.empty();
                                }
                                if (data.messages.length > 0) {
                                    messageTarget.append(data.messages);
                                } else {
                                    if (clearMessages) {
                                        messageTarget.append('<div class="no-messages">${text.format("theme-lib.community-activity.no-messages")}</div>');
                                    }
                                }
                                if (data.EOR == 'true') {
                                    $('#custom-loader-button').addClass('disabled');
                                } else {
                                    $('#custom-loader-button').removeClass('disabled');
                                }
                            } else {
                                $('#custom-loader-messages .errors', parentComponent).append(data.message);
                            }
                        },
                        complete: function(jqXHR, textStatus) {
                            $('.spinner', spinnerTarget).remove();
                        }
                    });
                };

                $('#community-activity-sorted-by').change(function() {
                    $('.tablinks[data-value="'+$(this).val()+'"]').addClass('active').siblings('.tablinks').removeClass('active');
                    <#-- first, clear out the current messages, then make ajax request with new list type. -->
                    var messageTarget = $('#custom-loader .message-list');
                    messageTarget.attr('data-attrib-message-list-type', $(this).val());
                    $(messageTarget).attr('data-attrib-current-page', '0');
                    getMessages($('#custom-loader'), true);
                });

                $('#custom-loader-button').click( function(evt) {
                    evt.preventDefault();
                    if ($(this).hasClass('disabled')) {
                        return;
                    }
                    var currentPage = null;
                    var messageTarget = $('#custom-loader .message-list');
                    try {
                        currentPage = parseInt($(messageTarget).attr('data-attrib-current-page'), 10);
                    } catch (e) {
                        currentPage = 0;
                    }
                    $(messageTarget).attr('data-attrib-current-page', (currentPage + 1));
                    getMessages($('#custom-loader-button'), false);
                });
                <#--  Start:This code is added as part of https://italent.atlassian.net/browse/ZOOM-5 -->
                
                let scrollPositions = [];

                function toggleContent(index, showMore) {
                    if (showMore) {
                        <#--  Save the current scroll position when showing more content for each post  -->
                        scrollPositions[index] = $(window).scrollTop();
                    }

                    $('.more-content').eq(index).toggle(showMore);
                    $('.less-content').eq(index).toggle(!showMore);
                    $('.show-more').eq(index).toggle(!showMore);
                    $('.show-less').eq(index).toggle(showMore);
    
                    if (!showMore && scrollPositions[index] !== undefined) {
                        <#--  Auto-scroll back to the original scroll position when showing less content  -->
                        $('html, body').animate({ scrollTop: scrollPositions[index] }, 'slow');
                    }
                }

                $(document).on('click', '.show-more', function() {
                    toggleContent($('.show-more').index(this), true);
                 });

                $(document).on('click', '.show-less', function() {
                    toggleContent($('.show-less').index(this), false);
                });

                <#-- Ends: https://italent.atlassian.net/browse/ZOOM-5 code-->

                $('.tablinks').click(function(evt) {
                    evt.preventDefault();
                    var listType=$(this).attr('data-value');
                    $(this).addClass('active').siblings('.tablinks').removeClass('active');
                    $('#community-activity-sorted-by').val(listType);
                    <#-- first, clear out the current messages, then make ajax request with new list type. -->
                    var messageTarget = $('#custom-loader .message-list');
                    messageTarget.attr('data-attrib-message-list-type', listType);
                    $(messageTarget).attr('data-attrib-current-page', '0');
                    getMessages($('#custom-loader'), true);
                });
            });
        })(LITHIUM.jQuery);
        </@liaAddScript>
    </#if>
</@compress>
<#--/custom community activity -->