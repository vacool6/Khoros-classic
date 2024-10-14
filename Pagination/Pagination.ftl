<#--  "custom.target_communities_dev_topics" is the SLE  -->


<div class="ideas_data" id='ideas_data'>
    <div class="pagination">
        <#assign offsetcount=0/>
        <#assign code=settings.name.get("custom.target_communities_dev_topics")>
        <#assign count = rest("2.0", "/search?q=" + "select count(*) from messages WHERE category.id = 'iTalent_POC'"?url).data.count/>
        
        <#if count?number lt 10>
            <#assign n = 1/>
        <#else>
            <#assign n = (count / 10)?ceiling />
        </#if>
    </div>
    <div id="print"></div>
    <@liaAddScript>
        let currentPage = 1;
        const totalPages = ${n};
        
        const apiCall = async (page = 1) => {
            let offset = (page - 1) * ${code};
            console.log("apiCall for page", page, "with offset", offset);
            let url = "/plugins/custom/salescontainer/italent2/genz_type2?offsetcount=" + offset;
            const apiData = await fetch(url);
            const resData = await apiData?.text();

            document.getElementById('print').innerHTML = resData;
            updatePagination(page);
        };

        (async () => {
            await apiCall();
        })();

        const prevPage = () => {
            if (currentPage > 1) {
                currentPage--;
                apiCall(currentPage);
            }
        };

        const nextPage = () => {
            if (currentPage < totalPages) {
                currentPage++;
                apiCall(currentPage);
            }
        };

        const goToPage = (page) => {
            currentPage = page;
            apiCall(page);
        };

        const updatePagination = (page) => {
            const paginationContainer = document.getElementById('pageNumbers');
            paginationContainer.innerHTML = ''; 

            let startPage = Math.max(1, page - 1);
            let endPage = Math.min(totalPages, page + 1);

            if (startPage === 1) {
                endPage = 3;
            }

            if (endPage > totalPages) {
                startPage = totalPages - 2;
                endPage = totalPages;
            }

            for (let i = startPage; i <= endPage; i++) {
                const pageButton = document.createElement('button');
                pageButton.innerText = i;
                pageButton.onclick = () => goToPage(i);
                pageButton.className = 'page-number';
                if (i === page) {
                    pageButton.classList.add('active');
                }
                paginationContainer.appendChild(pageButton);
            }
        };
    </@liaAddScript>
</div>

<button onclick="prevPage()" class="prev">Prev</button>
<div id="pageNumbers" class="page-numbers"></div> 
<button onclick="nextPage()" class="next">Next</button>

<style>
    .prev, .next {
        background-color: #3498db;
        color: white;
        border: none;
        padding: 10px 20px;
        font-size: 16px;
        cursor: pointer;
        outline: none;
        transition: background-color 0.3s ease;
    }

    .prev:hover, .next:hover {
        background-color: #2980b9;
    }

    .page-number {
        background-color: #f1f1f1;
        border: 1px solid #ccc;
        padding: 10px 15px;
        cursor: pointer;
        margin: 0 5px;
        font-size: 16px;
        outline: none;
    }

    .page-number.active {
        background-color: #3498db;
        color: white;
    }

    .page-number:hover {
        background-color: #2980b9;
        color: white;
    }

    .page-numbers {
        display: inline-block;
        margin: 0 10px;
    }

    span {
        font-size: 18px;
        margin: 0 5px;
    }
</style>

