<style>
.card-container {
  border: 1px solid black;
  padding : 2px;
  margin : 2px;
}
</style>

<#assign selectedOption = http.request.parameters.name.get("filterOption", "all") />

<#include "genZ_type3_filter.ftl" />
<@handleFilterOption selectedOption=selectedOption />

<div style="padding: 10px; margin-left: 5px; width: 30%;">
  <label>Filter By
    <select name="option" id="filterOption" onchange="handleChange()">
      <option value="all" <#if selectedOption == "all">selected</#if>>All</option>
      <option value="popular" <#if selectedOption == "popular">selected</#if>>Popular</option>
      <option value="recent" <#if selectedOption == "recent">selected</#if>>Recent</option>
      <option value="most-viewed" <#if selectedOption == "most-viewed">selected</#if>>Most Viewed</option>
    </select>
  </label>
</div>

  <#list Messages as item>
    <div class="card-container">
      <div class="text-container">
        <h3>${item.subject}</h3>
        <b>${item.id}</b>
      </div>
    </div>
  </#list>

<script>
const handleChange = () => {
  const filterOptionSelect = document.getElementById('filterOption');
  const selectedOption = filterOptionSelect.value;
  const Current_Url = new URL(location.href);
  Current_Url.searchParams.set('filterOption', selectedOption);
  window.location.href = Current_Url.toString();
};
</script>
