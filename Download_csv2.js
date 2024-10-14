const apiUrlBase =
  "/api/2.0/search?q=select * from messages where author.id = '30036'";

function decodeHtmlEntities(text) {
  var textarea = document.createElement("textarea");
  textarea.innerHTML = text;
  return textarea.value;
}

function cleanSpecialCharacters(text) {
  return text.replace(/[\u2018\u2019\u201c\u201d\u2013\u2014\uFFFD]/g, "");
}

function stripHtml(html) {
  const doc = new DOMParser().parseFromString(html, "text/html");
  return doc.body.textContent || "";
}

async function fetchAllData() {
  let allData = [];
  let nextCursor = "";

  try {
    while (true) {
      const apiUrl = nextCursor
        ? `${apiUrlBase} CURSOR "${nextCursor}"`
        : apiUrlBase;

      const response = await fetch(apiUrl);
      if (!response.ok) {
        throw new Error("Network response was not ok " + response.statusText);
      }

      const data = await response.json();
      allData = allData.concat(data.data.items);

      if (data.data.next_cursor) {
        nextCursor = data.data.next_cursor;
      } else {
        break;
      }
    }

    let csvContent =
      "ID,Subject,Body,Board Type,Board ID,Board Href,Board View Href," +
      "Author Type,Author ID,Author Href,Author View Href,Author Login," +
      "Conversation Type,Conversation ID,Conversation Href,Conversation View Href," +
      "Post Time,Post Time Friendly,Language,Visibility Scope,Moderation Status," +
      "Is Solution,Is Promoted,Can Accept Solution,Device ID,Depth," +
      "Popularity,Read Only,Edit Frozen,Metrics Views\n";

    console.log(">>", allData);
    allData.forEach((e) => {
      const cleanBody = cleanSpecialCharacters(
        decodeHtmlEntities(stripHtml(e.body))
      );
      const row = [
        e.id,
        `"${e.subject}"`,
        `"${cleanBody}"`,
        e.board.type,
        e.board.id,
        e.board.href,
        e.board.view_href,
        e.author.type,
        e.author.id,
        e.author.href,
        e.author.view_href,
        `"${e.author.login}"`,
        e.conversation.type,
        e.conversation.id,
        e.conversation.href,
        e.conversation.view_href,
        e.post_time,
        e.post_time_friendly,
        e.language,
        e.visibility_scope,
        e.moderation_status,
        e.is_solution,
        e.is_promoted,
        e.can_accept_solution,
        e.device_id,
        e.depth,
        e.popularity,
        e.read_only,
        e.edit_frozen,
        e.metrics.views,
      ];
      csvContent += row.join(",") + "\n";
    });

    const blob = new Blob([csvContent], { type: "text/csv;charset=utf-8;" });
    const link = document.createElement("a");
    const url = URL.createObjectURL(blob);
    link.setAttribute("href", url);
    link.setAttribute("download", "messages.csv");
    link.style.visibility = "hidden";
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  } catch (error) {
    console.error("There was a problem with the fetch operation:", error);
  }
}

fetchAllData();
