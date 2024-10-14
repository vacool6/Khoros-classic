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

   <#assign messageListType = "recent" />

   <#if http.request.parameters.name.get("label")??>
       <#assign label = http.request.parameters.name.get("label") />
       <#assign scope = coreNode.nodeType />
       <#assign label_query = " AND labels.text='"+label+"' " />
   <#else>
       <#assign label = "" />
   </#if>

   ${label}

   <#assign currentPage = (loadMoreObject.currentPage!"0")?number />
   <#assign nodeId = coreNode.id />
   <#assign initialPayload = (currentPage + 1) * pageSize />
   <#assign messagesCount = messageUtils.getMessagesCount(nodeId, label, messageListType, scope, allowedInteractionStyles) />

   <#if label?? && label?has_content>
       <#assign messages = messageUtils.getLazyLoadMessages(nodeId, label, messageListType, initialPayload, scope, 0, allowedInteractionStyles) />
   <#else>
       <#assign messages = messageUtils.getLazyLoadMessages(nodeId, label, messageListType, initialPayload, scope, 0, allowedInteractionStyles) />
   </#if>

   <#assign timezone = restadmin("users/id/${user.id}/settings/name/config.timezone").value />

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
                           <option value="replies" <#if messageListType == "replies">selected</#if>>${text.format("theme-lib.community-activity.replies")}</option>
                           <option value="topkudos" <#if messageListType == "topkudos">selected</#if>>${text.format("theme-lib.community-activity.kudos")}</option>
                           <option value="feature" <#if messageListType == "feature">selected</#if>>Featured post</option>
                       </select>

                       <#if coreNode.nodeType != 'category'>
                           <@component id="theme-lib.start-conversation-button" />
                       </#if>
                   </div>
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
                   <div id="load-more-aria" role="status" aria-live="assertive" aria-atomic="true" class="sr-only"></div>
               </section>
           </section>
       </div>

       <@liaAddScript>
       ;(function($) {
           $(document).ready(function() {

               document.querySelectorAll('.like-btn').forEach(button => {
                   const mesId = button.getAttribute('data-msg-index');
                   button.addEventListener('click', () => {
                       console.log(mesId);

                       $.ajax({
                          type: 'POST',
                          url: '/api/2.0/messages/'+ mesId + '/kudos',
                          headers: {
                            accept: 'application/json',
                            'content-type': 'application/json'
                          },
                          data: JSON.stringify({data: {type: 'kudo'}}),
                          success: function(response) {
                            console.log(response);
                            alert("You have liked the post!");
                            window.location.reload();
                          },
                          error: function(err) {
                            console.error(err);
                          }
                        });
                   });
               });

               var getMessages = function (spinnerTarget, clearMessages) {
                   var parentComponent = $('#custom-loader');
                   var messageTarget = $('.message-list', parentComponent);
                   var currentPage = null;
                   var returnedMessageCount = 0;
                   try {
                       currentPage = parseInt($(messageTarget).attr('data-attrib-current-page'), 10);
                   } catch (e) {
                       currentPage = 0;
                   }

                   $.ajax({
                       type: 'post',
                       url: '${commonUtils.getEndpointUrl("theme-lib.community-activity")}',
                       dataType: 'json',
                       data: {
                           "currentPage": currentPage,
                           "node": "${coreNode.id}",
                           "scope": "${scope}",
                           "messageListType": $(messageTarget).attr('data-attrib-message-list-type'),
                           "allowedInteractionStyles": "${allowedInteractionStyles}"
                       },
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
                               let totalListSize = messageTarget.children(".custom-message-tile").length;
                               console.log(data, "data");
                               if (clearMessages) {
                                   messageTarget.empty();
                               }
                               if (data.messages.length > 0) {
                                   messageTarget.append(data.messages);
                                   let messageMatch = data.messages.match(/custom-message-tile/gi);
                                   console.log(messageMatch, "messageMatch")
                                   returnedMessageCount = messageMatch ? messageMatch.length : 0;
                               } else {
                                   if (clearMessages) {
                                       messageTarget.append('<div class="no-messages">${text.format("theme-lib.community-activity.no-messages")}</div>');
                                   }
                               }
                               totalListSize = messageTarget.children(".custom-message-tile").length;

                               if (data.EOR == 'true') {
                                   $('#custom-loader-button').hide();
                                   $('#custom-loader-button').addClass('disabled');
                               } else {
                                   $('#custom-loader-button').removeClass('disabled');
                               }

                               let statusString = "";
                               if (returnedMessageCount === 1){
                                   statusString += " ${text.format('theme-lib.load-more.aria.js.one-new-message-loaded')}";
                               } else {
                                   statusString += returnedMessageCount + " ${text.format('theme-lib.load-more.aria.js.new-messages-loaded')} ";
                               }
                               statusString += totalListSize + " ${text.format('theme-lib.load-more.aria.js.total-items-in-list')}";
                               $('#load-more-aria').text(statusString);

                               $("#custom-loader #custom-loader-messages .message-list .custom-message-tile").eq(-returnedMessageCount).find(':focusable')[0].focus();
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
                   var messageTarget = $('#custom-loader .message-list');
                   messageTarget.attr('data-attrib-message-list-type', $(this).val());
                   $(messageTarget).attr('data-attrib-current-page', '0');
                   getMessages($('#custom-loader'), true);
               });

               $('#custom-loader-button').click(function(evt) {
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
                   $(messageTarget).attr('data-attrib-current-page', currentPage + 1);
                   getMessages($(this), false);
               });

           });
       })(jQuery);
       </@liaAddScript>
   </#if>
</@compress>
