<script lang="ts">
  import Header from "@components/shared/Header.svelte";
  import Footer from "@components/shared/Footer.svelte";
  import Join from "@components/shared/Join.svelte";
  import LinkButton from "@src/components/shared/LinkButton.svelte";
  import Newsletter from "@components/shared/Newsletter.svelte";
  import ConnectButton from "@src/components/shared/ConnectButton.svelte";
  import { disconnectWallet } from "@utils/connection";
  import { onDestroy } from "svelte";
  import { get } from "svelte/store";
  import { setMessage } from "@src/store/toast";
  import { actors } from "@src/store/actor";
  import type { Activity, Mission } from "@canisters/hub/hub.did.d";
  import type { Reward } from "@canisters/accessories/accessories.did.d";
  import { user } from "@src/store/user";
  import { getCumulativeActivity, getCompletedMissions, getRecordedRewards } from "@utils/activity";
  import ActivityComponent from "@src/components/profile/Activity.svelte";
  import MissionComponent from "@src/components/profile/Mission.svelte";
  import RewardsComponent from "@src/components/profile/Rewards.svelte";

  let editing = false;
  let mode = "informations";

  let activity: Activity | null = null;
  let completed: [Mission, bigint][] | null = null;
  let rewards: [Reward][] | null | [] = null;

  $: if (mode === "activity") {
    if (!activity) {
      getActivity();
    }
  }

  $: if (mode === "missions") {
    if (!completed) {
      getCompleted();
    }
  }

  $: if (mode === "rewards") {
    if (!rewards) {
      getRewards();
    }
  }

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

  function changeMode(new_mode: string) {
    mode = new_mode;
  }

  async function getActivity() {
    activity = await getCumulativeActivity(userProfile.principal);
  }

  async function getCompleted() {
    completed = await getCompletedMissions(userProfile.principal);
  }

  async function getRewards() {
    rewards = await getRecordedRewards(userProfile.principal);
    console.log("Rewards : ", rewards);
  }
</script>

<Header />
<div class="page-header">
  <h1>Profile</h1>
</div>
{#if userProfile.loggedIn}
  <div class="menu-choice">
    <button class="secondary" on:click={() => changeMode("informations")}> Informations </button>
    <button class="secondary" on:click={() => changeMode("activity")}> Activity </button>
    <button class="secondary" on:click={() => changeMode("missions")}> Missions </button>
    <button class="secondary" on:click={() => changeMode("rewards")}> Rewards </button>
  </div>
{/if}
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
  {:else if mode === "informations"}
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
  {:else if mode === "activity"}
    <!-- <div class="button-col">
      <button class="secondary-button">Cumulative</button>
      <button class="secondary-button">Daily</button> 
    </div> -->
    {#if activity}
      <ActivityComponent {activity} />
    {:else}
      <div class="not-logged-in">
        <p>No activity detected.</p>
      </div>
    {/if}
  {:else if mode === "missions"}
    {#if completed}
      <div class="mission-card">
        <MissionComponent {completed} />
      </div>
    {:else}
      <div class="not-logged-in">
        <p>No missions completed.</p>
      </div>
    {/if}
  {:else if mode === "rewards"}
    {#if rewards}
      <div class="reward-card">
        <RewardsComponent received_rewards={rewards} />
      </div>
    {:else}
      <div class="not-logged-in">
        <p>No rewards received.</p>
      </div>
    {/if}
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

  .menu-choice {
    display: flex;
    flex-direction: row;
    justify-content: space-around;
    align-items: center;
    margin: 20px auto;
    max-width: 1400px;
    gap: 50px;
  }

  .container {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    grid-gap: 40px;
    padding: 20px 20px !important;
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

  .mission-card {
    grid-column: span 3;
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
