<style>
   button{
     background-color: #007bff; 
     color: white; 
     padding: 0.5rem 1rem; 
     font-size: 16px; 
     border: none; 
     cursor: pointer; 
     font-weight:700;
     margin-right: 4px;
     border-radius: 4px;
  }

  button:active{
    transform:scale(0.95);
  }

  button:disabled{
    cursor:not-allowed;
    transform:scale(1);
  }

  .like-btn{
    border: 1px solid #007bff; 
    background-color : white;
  }

  .like-btn:hover{
     background-color: #fcfcfc; 
  }

  .comment-btn a{
    text-decoration:none;
    color:white;
  }

  .message-list{
    display: none;
  }
</style>


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
                          <option value="read" <#if messageListType == "read">selected</#if>> Read </option>
                          <option value="unread" <#if messageListType == "unread">selected</#if>> unRead</option>
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
             let userLikesArry = [];
const likeButtons = document.querySelectorAll('.like-btn');
const unlikeButtons = document.querySelectorAll('.unlike-btn');


 
             async function getCurUSerKudos(){
               const response = await fetch("/api/2.0/search?q=select * FROM kudos WHERE user.id = '" + ${user.id} + "'");
               const  data = await response.json();
               userLikesArry = data.data.items;

               if(data){
                document.querySelector('.message-list').style.display = "block";
               }

               // Like button functionality

for (let i = 0; i < likeButtons.length; i++) {
   let currIdx = i;
   let showLike = false;

  (function(button) {
    let mesId = button.getAttribute('data-msg-index');


     for(let i of userLikesArry){
      if(i.message.id === mesId){
        showLike = false;
        break;
      }else{
       showLike = true;
      }
     }

    if(showLike){
     unlikeButtons[currIdx].style.display = "none";
    }else{
     likeButtons[currIdx].style.display = "none";
    }

    button.addEventListener('click', function() {
      let buttons = document.querySelectorAll('.like-btn, .unlike-btn, .comment-btn');
      for (let j = 0; j < buttons.length; j++) {
        buttons[j].setAttribute('disabled', true);
      }

      $.ajax({
        type: 'POST',
        url: '/api/2.0/messages/' + mesId + '/kudos',
        headers: {
          accept: 'application/json',
          'content-type': 'application/json'
        },
        data: JSON.stringify({ data: { type: 'kudo' } }),
        success: function(response) {
          console.log(response);
          alert('You have liked the post!');
          window.location.reload();
        },
        error: function(err) {
          console.error(err);
        }
      });
    });
  })(likeButtons[i]);
}

// Unlike button functionality

for (let i = 0; i < unlikeButtons.length; i++) {
  (function(button) {
    let mesId = button.getAttribute('data-msg-index');

    button.addEventListener('click', function() {
      let buttons = document.querySelectorAll('.like-btn, .unlike-btn, .comment-btn');
      for (let j = 0; j < buttons.length; j++) {
        buttons[j].setAttribute('disabled', true);
      }

      $.ajax({
        type: 'DELETE',
        url: '/api/2.0/messages/' + mesId + '/kudos',
        headers: {
          accept: 'application/json',
          'content-type': 'application/json'
        },
        success: function(response) {
          console.log(response);
          alert('You have unliked the post!');
          window.location.reload();
        },
        error: function(err) {
          console.error(err);
        }
      });
    });
  })(unlikeButtons[i]);
}


                
             } 

             getCurUSerKudos()
 
               let getMessages = function (spinnerTarget, clearMessages) {
                   let parentComponent = $('#custom-loader');
                   let messageTarget = $('.message-list', parentComponent);
                   let currentPage = null;
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
                           if (data.status == '${STATUS_SUCCESS}') {
                               if (clearMessages) {
                                   messageTarget.empty();
                               }
                            <#--  This code is changed as part of devlopement https://italent.atlassian.net/browse/TOAST-4-->
                               if (data.messages.length > 0) {
                                   $('#custom-loader-button').css('display','block'); 
                                   messageTarget.append(data.messages);
                               } else {
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
                   let messageTarget = $('#custom-loader .message-list');
                   messageTarget.attr('data-attrib-message-list-type', $(this).val());
                   $(messageTarget).attr('data-attrib-current-page', '0');
                   getMessages($('#custom-loader'), true);
               });
 
               $('#custom-loader-button').click( function(evt) {
                   evt.preventDefault();
                   if ($(this).hasClass('disabled')) {
                       return;
                   }
                   let currentPage = null;
                   let messageTarget = $('#custom-loader .message-list');
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