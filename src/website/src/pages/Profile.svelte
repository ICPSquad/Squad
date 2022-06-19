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
      setMessage("Updating your profile...", "waiting");
      const avatarActor = get(actors).avatarActor;
      console.log("User profile", userProfile);
      const result = await avatarActor.modify_profile(
        userProfile.username ? [userProfile.username] : [],
        userProfile.email ? [userProfile.email] : [],
        userProfile.discord ? [userProfile.discord] : [],
        userProfile.twitter ? [userProfile.twitter] : []
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

  const setDefaultAvatar = (avatarDefaultUrl: string) => {
    // TO DO - SAVE TO CANISTER

    userProfile = {
      ...userProfile,
      avatarDefault: avatarDefaultUrl,
    };
    user.set({ ...userProfile });
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
  {:else}
    <div class="avatar-col">
      <img src={`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/?&tokenid=${userProfile.avatarDefault}`} alt="ICP Squad Avatar" class="avatar" />
      {#if userProfile.avatars.length > 1}
        <div class="label">DEFAULT AVATAR</div>
        {#each userProfile.avatars as tokenIdentifier}
          <img on:click={() => setDefaultAvatar(tokenIdentifier)} src={`https://jmuqr-yqaaa-aaaaj-qaicq-cai.raw.ic0.app/?&tokenid=${userProfile.avatarDefault}`} alt="ICP Squad Avatar" />
        {/each}
      {/if}
      <LinkButton to="/add-accessory">
        <button class="secondary"> MINT & ADD ACCESSORIES </button>
      </LinkButton>
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
      <div class="field">
        <div class="label">WALLET CONNECTED</div>
        <div class="value small">{userProfile.principal}</div>
        <button on:click={disconnectWallet} class="secondary disconnect">Disconnect Wallet</button>
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

  h1,
  button {
    --page-feature-color: #{$yellow};
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

  button {
    background-color: var(--page-feature-color);
    color: $black;
    margin-bottom: 20px;
    &.secondary {
      color: $white;
    }
    &.disconnect {
      margin-top: 20px;
    }
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

  img.thumbnail {
    width: 60px;
    margin: 0 10px 20px 0;
    display: inline-block;
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
