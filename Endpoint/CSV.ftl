<#assign freeMarkerEndpoint = "/plugins/custom/salescontainer/italent2/genz_type1" />

<button id="fetchDataButton">Download CSV</button>

<@liaAddScript>
(function($) {
    $(document).ready(function() {
        $('#fetchDataButton').click(function() {
            var authorId = ${user.id};
            if (authorId) {
                $.ajax({
                    url: "${freeMarkerEndpoint}?id=" + authorId,
                    method: "GET",
                    success: function(response) {
                        console.log("Response received:", response);
                        var data = response.messages || [];
                        if (Array.isArray(data)) {
                            if (data.length === 0) {
                                console.error('No data found in the response.');
                                return;
                            }
                            
                            var csvContent = "ID,Board ID,Subject,Href,View Href\n";
                            data.forEach(function(item) {
                                var row = [
                                    item.id || '',
                                    item.board_id || '',
                                    '"' + (item.subject || "").replace(/"/g, '""') + '"',
                                    item.href || '',
                                    item.view_href || ''
                                ];
                                csvContent += row.join(",") + "\n";
                            });
                            
                            var blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
                            var link = document.createElement("a");
                            var url = URL.createObjectURL(blob);
                            link.setAttribute("href", url);
                            link.setAttribute("download", "messages.csv");
                            document.body.appendChild(link);
                            link.click();
                            document.body.removeChild(link);
                        } else {
                            console.error('Response data is not an array:', data);
                        }
                    },
                    error: function() {
                        console.error('API Call Failed');
                    }
                });
            } else {
                console.error('Author ID is required');
            }
        });
    });
})(LITHIUM.jQuery);
</@liaAddScript>
