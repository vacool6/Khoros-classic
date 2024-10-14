async function fetchAndDownloadCSV() {
  try {
    const response = await fetch(
      "/api/2.0/search?q=select * from messages where author.id = '30036'"
    );
    const messages = await response.json();

    let csvContent = "ID,Subject,Body,Board ID,Href,View Href\n";

    messages.data.items.forEach((e) => {
      // Removes HTML tags
      const cleanBody = e.body.replace(/<\/?[^>]+(>|$)/g, "");
      const row = [
        e.id,
        `"${e.subject}"`,
        `"${cleanBody}"`,
        e.board.id,
        e.href,
        e.view_href,
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
    console.error("Error fetching user data:", error);
  }
}

fetchAndDownloadCSV();
