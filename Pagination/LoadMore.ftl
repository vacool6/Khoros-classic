<#--  "custom.target_communities_dev_topics" is the SLE  -->

<div class="ideas_data" id='ideas_data'>
    <div class="pagination">
        <#assign offsetcount=0/>
        <#assign code=settings.name.get("custom.target_communities_dev_topics")>
        <#assign count = rest("2.0", "/search?q=" + "select count(*) from messages WHERE category.id = 'iTalent_POC'"?url).data.count/>
    </div>
    <div id="print"></div>
    <@liaAddScript>
        let offset = 0;
        const limit = ${code}; 
        const apiCall = async (append = false) => {
            console.log("Fetching items with offset", offset);
            let url = "/plugins/custom/salescontainer/italent2/genz_type2?offsetcount=" + offset;
            const apiData = await fetch(url);
            const resData = await apiData?.text();
            
            if (append) {
                document.getElementById('print').innerHTML += resData;
            } else {
                document.getElementById('print').innerHTML = resData;
            }
        };

        (async () => {
            await apiCall();
        })();

        const loadMore = () => {
            offset += limit; 
            apiCall(true);  
        };
    </@liaAddScript>
</div>

<button onclick="loadMore()" class="load-more">Load More</button>
