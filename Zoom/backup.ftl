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

<#--  Sameer mod ends  -->
