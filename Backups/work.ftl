<#-- custom community activity -->
<#import "theme-lib.common-functions.ftl" as commonUtils />
<#import "theme-lib.community-activity-macros.ftl" as messageUtils />
 
<@compress single_line=true>
   <#assign pageSize = settings.name.get("layout.messages_per_page_linear", "5")?number />
   <#assign scope = (env.context.component.getParameter('scope'))!"all" />
   <#assign allowedInteractionStyles = coreNode.settings.name.get("custom.allowed_interaction_styles", page.interactionStyle) />
   <#assign sumThreadKudosCount = coreNode.settings.name.get("layout.sum_thread_kudos", "false") />
   <#assign loadMoreData = {"messageListType": "recent", "currentPage": "0"} />
   <#assign loadMoreObject = http.session.attributes.name.get("${coreNode.id}Loader", utils.json.toJson(loadMoreData)) />
   <#attempt>
       <#assign loadMoreObject = utils.json.fromJson(loadMoreObject) />
   <#recover>
       <#assign loadMoreObject = loadMoreData />
   </#attempt>
   <#assign messageListType = loadMoreObject.messageListType!"recent" />
   <#assign currentPage = (loadMoreObject.currentPage!"0")?number />
   <#assign nodeId = coreNode.id />
   <#assign initialPayload = (currentPage + 1) * pageSize />
   <#assign messagesCount = messageUtils.getMessagesCount(nodeId, messageListType, scope, allowedInteractionStyles) />
   <#assign messages = messageUtils.getLazyLoadMessages(nodeId, messageListType, initialPayload, scope, 0, allowedInteractionStyles) />
 
   <#assign timezone =restadmin("users/id/${user.id}/settings/name/config.timezone").value />
 
   <#if messages?size gt -1>
       <div class="custom-community-activity" id="custom-loader">
           <section>
               <header>
                   <h2>${text.format("theme-lib.community-activity.title", coreNode.title)}</h2>
                   <#--  This code is changed as part of devlopement https://italent.atlassian.net/browse/TOAST-4--> 
                   <#if page.name == 'CommunityPage'>
                      <div> 
                        <select id="community-activity-sorted-by">
                          <option value="replies" <#if messageListType == "replies">selected</#if>>${text.format("theme-lib.community-activity.replies")}</option>
                          <option value="topkudos" <#if messageListType == "topkudos">selected</#if>>${text.format("theme-lib.community-activity.kudos")}</option>
                        <#if !user.anonymous>
                          <option value="feature" <#if messageListType == "feature">selected</#if>>${text.format("theme-lib.community-activity.feature")}</option>                    
                        </#if>                    
                        </select> 
                      </div>
                    <#else>
                      <div>
                        <label for="community-activity-sorted-by">${text.format("sortingbar.sortby")}</label>
                        <select id="community-activity-sorted-by">
                          <option value="recent" <#if messageListType == "recent">selected</#if>>${text.format("theme-lib.community-activity.recent")}</option>
                          <option value="views" <#if messageListType == "views">selected</#if>>${text.format("theme-lib.community-activity.views")}</option>
                          <option value="replies" <#if messageListType == "replies">selected</#if>>${text.format("theme-lib.community-activity.replies")}</option>
                          <option value="topkudos" <#if messageListType == "topkudos">selected</#if>>${text.format("theme-lib.community-activity.kudos")}</option>
                          <option value="feature" <#if messageListType == "feature">selected</#if>> featured posts </option>        
                        </select>
                        <@component id="theme-lib.start-conversation-button" />
                      </div>
                    </#if>
               </header>
               <section id="custom-loader-messages">
                   <div class="errors"></div>
                   <div class="message-list" data-attrib-current-page="${loadMoreObject.currentPage}" data-attrib-message-list-type="${loadMoreObject.messageListType}">
                       <#setting time_zone = timezone>
                       <#list messages as msg>
                           <@messageUtils.printMsg msg msg?index messages?size false sumThreadKudosCount/>
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
                       data: {"currentPage": currentPage, "node": "${coreNode.id}", "scope":"${scope}", "messageListType": $(messageTarget).attr('data-attrib-message-list-type'), "allowedInteractionStyles": "${allowedInteractionStyles}"},
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
                        console.log("Inside success");
                           if (data.status == '${STATUS_SUCCESS}') {
                               if (clearMessages) {
                                   messageTarget.empty();
                               }
                               console.log(">>>",data);
                            <#--  This code is changed as part of devlopement https://italent.atlassian.net/browse/TOAST-4-->
                               if (data.messages.length > 0) {
                                                        console.log("Inside IF");

                                   $('#custom-loader-button').css('display','block'); 
                                   messageTarget.append(data.messages);
                               } else {
                                                        console.log("Inside Else");
                                   $('#custom-loader-button').css('display','none'); 
                                   if (clearMessages) {
                                       messageTarget.append('<div class="no-messages">${text.format("theme-lib.community-activity.no-messages")}</div>');
                                   }
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
           });
       })(LITHIUM.jQuery);
       </@liaAddScript>
   </#if>
</@compress>
<#--/custom community activity -->