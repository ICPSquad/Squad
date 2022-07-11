<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import { disconnectWallet } from "@utils/connection";
  import { onDestroy } from "svelte";
  import { get } from "svelte/store";
  import { setMessage } from "@src/store/toast";
  import { actors } from "@src/store/actor";
  import { user } from "@src/store/user";

  import LinkButton from "@src/components/shared/LinkButton.svelte";
  import ConnectButton from "@src/components/shared/ConnectButton.svelte";

  let editing = false;

  let userProfile = { ...get(user) };

  const unsubcribe = user.subscribe(() => {
    userProfile = { ...get(user) };
  });

  const handleSave = async () => {
    try {
      setMessage("Updating your information...", "waiting");
      const avatarActor = get(actors).avatarActor;
      const result = await avatarActor.modify_profile(
        userProfile.username ? [userProfile.username] : [],
        userProfile.email ? [userProfile.email] : [],
        userProfile.discord ? [userProfile.discord] : [],
        userProfile.twitter ? [userProfile.twitter] : [],
        userProfile.avatarDefault
      );

      if ("ok" in result) {
        setMessage("Profile updated successfully!", "success", 3000);
        user.set({ ...userProfile });
      } else {
        setMessage(result.err, "error", 3000);
      }
    } catch (e) {
      setMessage(e.message, "error", 3000);
    }
    editing = false;
  };

  const handleCancel = () => {
    userProfile = { ...get(user) };
    editing = false;
  };

  const setDefaultAvatar = (tokenIdentifier: string) => {
    userProfile = {
      ...userProfile,
      avatarDefault: tokenIdentifier,
    };
    user.set({ ...userProfile });
  };

  const handleDownload = async () => {
    fetch(`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/?&tokenid=${userProfile.avatarDefault}`).then((result) => {
      result.blob().then((blob) => {
        var image = new Image();
        image.width = 800;
        image.height = 800;
        var url = window.URL.createObjectURL(blob);
        var canvas = document.getElementById("c") as HTMLCanvasElement;
        canvas.width = 800;
        canvas.height = 800;
        canvas.style.display = "none";
        image.onload = function () {
          canvas.getContext("2d").drawImage(image, 0, 0);
          var uri = canvas.toDataURL("image/png").replace("image/png", "octet/stream");
          var a = document.createElement("a");
          a.style.display = "none";
          document.body.appendChild(a);
          a.href = uri;
          a.download = "dSquad_avatar.png";
          a.click();
          window.URL.revokeObjectURL(uri);
          document.body.removeChild(a);
        };
        image.src = url;
      });
    });
  };

  onDestroy(() => {
    unsubcribe();
  });
</script>

<Header />
<div class="page-header">
  <h1>Profile</h1>
</div>
<div class="container">
  {#if !userProfile.loggedIn}
    <div class="not-logged-in">
      <p>Please connect a wallet to continue</p>
      <ConnectButton />
    </div>
  {:else if !userProfile.avatarDefault}
    <div class="not-logged-in">
      <p>No avatar detected. Please create your avatar first.</p>
      <LinkButton to="/create-avatar">
        <button> Create </button>
      </LinkButton>
    </div>
  {:else}
    <div class="avatar-col">
      <img src={`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/?&tokenid=${userProfile.avatarDefault}`} alt="ICP Squad Avatar" class="avatar" />
      <LinkButton to="/add-accessory">
        <button class="secondary"> MINT & ADD ACCESSORIES </button>
      </LinkButton>
      <button class="seconday" on:click={handleDownload}> Download </button>
      <canvas id="c" />
    </div>
    <div class="user-details-col">
      <div class="field">
        <div class="label">USERNAME</div>
        {#if editing}
          <input bind:value={userProfile.username} type="text" class="value" placeholder="Username" />
        {:else if !userProfile.username}
          <div on:click={() => (editing = true)} class="add-button">Add</div>
        {:else}
          <div class="value">{userProfile.username}</div>
        {/if}
      </div>
      <div class="field">
        <div class="label">EMAIL</div>
        {#if editing}
          <input bind:value={userProfile.email} type="text" class="value" placeholder="email@email.com" />
        {:else if !userProfile.email}
          <div on:click={() => (editing = true)} class="add-button">Add</div>
        {:else}
          <div class="value">{userProfile.email}</div>
        {/if}
      </div>
      <div class="field">
        <div class="label">TWITTER</div>
        {#if editing}
          <input bind:value={userProfile.twitter} type="text" class="value" placeholder="@twitterhandle" />
        {:else if !userProfile.twitter}
          <div on:click={() => (editing = true)} class="add-button">Add</div>
        {:else}
          <div class="value">{userProfile.twitter}</div>
        {/if}
      </div>
      <div class="field">
        <div class="label">DISCORD</div>
        {#if editing}
          <input bind:value={userProfile.discord} type="text" class="value" placeholder="discordusername:XXXX" />
        {:else if !userProfile.discord}
          <div on:click={() => (editing = true)} class="add-button">Add</div>
        {:else}
          <div class="value">{userProfile.discord}</div>
        {/if}
      </div>
      {#if userProfile.avatars.length > 1 && editing}
        <div class="label">DEFAULT AVATAR</div>
        <div class="list-avatars">
          {#each userProfile.avatars as tokenIdentifier}
            <img
              on:click={() => setDefaultAvatar(tokenIdentifier)}
              src={`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/?&tokenid=${tokenIdentifier}`}
              alt="ICP Squad Avatar"
              class={tokenIdentifier === userProfile.avatarDefault ? "selected" : ""}
            />
          {/each}
        </div>
      {/if}
      <div class="field">
        <div class="label">WALLET CONNECTED</div>
        <div class="value small">{userProfile.principal}</div>
        <button on:click={disconnectWallet} class="secondary disconnect">Sign out </button>
      </div>
    </div>
    <div class="button-col">
      {#if editing}
        <button on:click={handleSave}>SAVE PROFILE</button>
        <button on:click={handleCancel} class="secondary">CANCEL</button>
      {:else}
        <button on:click={() => (editing = true)}>EDIT PROFILE</button>
      {/if}
    </div>
  {/if}
</div>
<Join />
<Newsletter />
<Footer />

<style lang="scss">
  @use "../styles" as *;

  h1 {
    --page-feature-color: #{$yellow};
  }

  button {
    --page-feature-color: #{$yellow};
    color: $black;
    margin-bottom: 20px;
    &.secondary {
      color: $white;
    }
    &.disconnect {
      margin-top: 20px;
    }
  }

  .list-avatars {
    display: flex;
    flex-direction: row;

    justify-content: space-between;
    img {
      width: 200px;
      height: 200px;
      margin: 20px 10px;
      border-radius: 10px;
      cursor: pointer;
      z-index: 10;
    }
  }

  img {
    border-radius: 10px;
  }

  .container {
    display: grid;
    grid-template-columns: 3fr 6fr 3fr;
    grid-gap: 40px;
  }

  .field {
    margin-bottom: 30px;
  }

  .label {
    margin-bottom: 4px;
  }

  .value,
  .add-button {
    font-weight: bold;
    font-size: 30px;
    &.small {
      font-size: 14px;
    }
  }

  .add-button {
    text-decoration: underline;
    color: $darkgrey;
  }

  input {
    background-color: transparent;
    border-color: $white;
    color: inherit;
    padding: 2px 8px;
    border: 1px solid $white;
    box-shadow: none;
    outline: none;
    border-radius: 10px;
    width: 100%;
  }

  img.avatar {
    margin-bottom: 40px;
  }

  .not-logged-in {
    grid-column: span 3;
  }

  img {
    &.selected {
      border: 2px solid $green;
    }
  }

  @media (max-width: 800px) {
    .container {
      grid-template-columns: 180px 1fr;
    }

    .avatar-col {
      grid-row: span 2;
    }

    .button-col {
      grid-row-start: 1;
      grid-column-start: 2;
    }

    .value,
    .add-button {
      font-size: 14px;
    }
  }
</style>
