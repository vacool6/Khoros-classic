<#assign freeMarkerEndpoint = "/plugins/custom/salescontainer/italent2/genz_type1" />

<button id="fetchDataButton">Fetch Data</button>

<@liaAddScript>
(function($) {
    $(document).ready(function() {
        $('#fetchDataButton').click(function() {
            var authorId =  ${user.id};
            console.log('User ID -', ${user.id});
            if (authorId) {
                $.get("${freeMarkerEndpoint}?id=" + authorId).done(function(data) {
                    console.log("${freeMarkerEndpoint}?authorId=" + authorId);
                    console.log('API Call Successful:', data);
                }).fail(function() {
                    console.error('API Call Failed');
                });
            } else {
                console.error('Author ID is required');
            }
        });
    });
})(LITHIUM.jQuery);
</@liaAddScript>
