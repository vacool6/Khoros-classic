<style>
  section {
    background-image: url("https://italent2.demo.lithium.com/html/assets/champion-badge.png?version=preview");
    min-height: 100vh;
    background-position: center;
    background-repeat: no-repeat;
    background-size: cover;
  }
</style>

<section>
  <#assign flow =settings.name.get("custom.target_communities_dev_flow")>
  <#assign pointer = text.format("king-bullet") />

  <h2>${pointer} Title :</h2>
  <br />
  <br />
  <h2>${pointer} Asset :</h2>
  <img
    src=" https://italent2.demo.lithium.com/html/assets/promotionsImg.png?version=preview"
    alt="Logo"
    height="50"
    width="50"
  />
  <br />
  <br />
  <h2>${pointer} Dev-flow :</h2>
  <p>${flow}</p>
  <br />
</section>

