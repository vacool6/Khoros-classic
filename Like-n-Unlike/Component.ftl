<style>
  .container {
    width: 100%;
  }

  .container h1 {
    color: #333;
  }

  .card {
    background-color: #f9f9f9;
    padding: 15px;
    margin: 15px 0;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    width: 100%;
  }

  .card p {
    margin: 0;
    font-size: 16px;
    color: #333;
  }

  .response {
    margin-top: 20px;
  }

  button{
     background-color: #007bff; 
     color: white; 
     padding: 0.5rem; 
     font-size: 16px; 
     border: none; 
     border-radius: 5px; 
     cursor: pointer; 
     font-weight:700;
     margin-right: 4px;
  }

  button:active{
    transform:scale(0.95);
  }

  button:disabled{
    cursor:not-allowed;
    background-color: grey; 
    transform:scale(1);
  }

  .comment-btn a{
    text-decoration:none;
  }
</style>

<div class="container">
  <h1>API Call</h1>
  <div class="response" id="response">Loading data...</div>
</div>

<@liaAddScript> 

 console.log('User ID -', ${user.id});

  function likeHandler(id) {
    const buttons = document.querySelectorAll('.like-btn, .unlike-btn, .comment-btn');

    buttons.forEach(button => {
     button.setAttribute("disabled", true);
    });

    fetch("/api/2.0/messages/" + id + "/kudos", {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ data: { type: "kudo" } }),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then((data) => {
        console.log(data);
        alert("You have liked the post!");
        window.location.reload();
      })
      .catch((error) => {
        console.error("There was a problem with the fetch operation:", error);
      });
  }

  function unlikeHandler(id) {
    const buttons = document.querySelectorAll('.like-btn, .unlike-btn, .comment-btn');

    buttons.forEach(button => {
     button.setAttribute("disabled", true);
    });

    fetch("/api/2.0/messages/" + id + "/kudos", {
      method: "DELETE",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then((data) => {
        console.log(data);
        alert("You have un-liked the post!");
        window.location.reload();
      })
      .catch((error) => {
        console.error("There was a problem with the fetch operation:", error);
      });
  }

  let userLikesArry = [];
 
  async function getCurUSerKudos(){
    const response = await fetch("/api/2.0/search?q=select * FROM kudos WHERE user.id = '" + ${user.id} + "'");
    const  data = await response.json();
    userLikesArry = data.data.items;
  } 

 getCurUSerKudos()
 
 window.addEventListener("load", async () => {
  try {
    const response = await fetch(
      "/api/2.0/search?q=select * FROM messages WHERE category.id = 'iTalent_POC'"
    );
    const data = await response.json();
    const responseDiv = document.getElementById("response");

    responseDiv.innerHTML = '';

    const fetchPromises = data.data.items.map(async function (item) {
     let showLike = false;

     for(let i of userLikesArry){
      if(i.message.id === item.id){
        showLike = false;
        break;
      }else{
       showLike = true;
      }
     }

      const kudosResponse = await fetch(
        "/api/2.0/search?q=SELECT * FROM kudos WHERE message.id = '" + item.id + "'"
      );

      const kudosData = await kudosResponse.json();

      const card = document.createElement('div');
      card.className = 'card';

      const idParagraph = document.createElement('p');
      idParagraph.innerHTML = "<strong>ID:</strong> " + item.id;
      card.append(idParagraph);

      const subjectParagraph = document.createElement('p');
      subjectParagraph.innerHTML = "<strong>Subject:</strong> " + item.subject;
      card.append(subjectParagraph);

      const kudosParagraph = document.createElement('p');
      kudosParagraph.innerHTML = "<strong>Kudos Count:</strong> " + kudosData.data.items.length;
      card.append(kudosParagraph);

      const viewsParagraph = document.createElement('p');
      viewsParagraph.innerHTML = "<strong>Views:</strong> " + item.metrics.views;
      card.append(viewsParagraph);

      if(!showLike){
         const unlikeButton = document.createElement('button');
         unlikeButton.className = 'unlike-btn';
         unlikeButton.innerText = 'Unlike 👎';
         unlikeButton.addEventListener('click', () => unlikeHandler(item.id));
         card.append(unlikeButton);
      } else{
         const likeButton = document.createElement('button');
         likeButton.className = 'like-btn';
         likeButton.innerText = 'Like 👍';
         likeButton.addEventListener('click', () => likeHandler(item.id));
         card.append(likeButton);
      }
      
      const commentButton = document.createElement('button');
      commentButton.className = 'comment-btn';
      const commentLink = document.createElement('a');
      commentLink.href = item.view_href;
      commentButton.innerText = 'Comment 👻';
      commentButton.addEventListener('click', () => window.open(commentLink.href));
      card.append(commentButton);

      responseDiv.append(card);
    });

    await Promise.all(fetchPromises);

  } catch (error) {
    console.error("Error fetching data:", error);
    document.getElementById("response").textContent = "Error fetching data";
  }
});

</@liaAddScript>
