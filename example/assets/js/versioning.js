let polling = true;
let loadedVersion = null;

let pageReloadTimeout = 60000;
let versionCheckTimeout = 60000 * 15;

const displayWarning = () => {
  let fragment = document.createDocumentFragment();
  let div = document.createElement("div");
  div.className = "alert alert-warning";

  let text = document.createElement("div");
  text.innerHTML = "The site has updated and will be reloading shortly. ";

  let link = document.createElement("a");
  link.href = "#";
  link.addEventListener("click", (e) => {
    location.reload();
  });
  link.innerHTML = "Reload now.";

  text.appendChild(link);
  div.appendChild(text);

  fragment.appendChild(div);

  let container = document.querySelector(".alerts");
  container.prepend(fragment);

  setTimeout(() => {
    location.reload();
  }, pageReloadTimeout);
};

const checkVersion = () => {
  if (!polling) { return; }

  fetch("/version").then((data) => {
    return data.json();
  }).then((data) => {
    if (loadedVersion) {
      if (loadedVersion.assets < data.assets) {
        polling = false;
        displayWarning();
      }
    } else {
      loadedVersion = data;
    }
  });

  setTimeout(checkVersion, versionCheckTimeout);
};

checkVersion();
