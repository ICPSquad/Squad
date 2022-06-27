<script lang="ts">
  import emailjs from "@emailjs/browser";
  import Checkbox from "../shared/Checkbox.svelte";

  let formSubmitted = false;

  const handleSubmit = () => {
    let sendingTemplate = convertInterestsToEmailjsTemplate(templateParams);

    emailjs.send("service_77ki0jv", "template_o8m0n65", sendingTemplate, "user_gExhHHDDkYwDETmorUTmI").then(
      (response) => {
        formSubmitted = true;
      },
      (err) => {
        console.log("FAILED...", err);
      }
    );
    formSubmitted = true;
  };

  type InterestOptions = {
    integratingProject: boolean;
    hostingMission: boolean;
    airdroppingAssets: boolean;
    brandedAccessories: boolean;
  };

  type EmailTemplateProps = {
    projectName: string;
    yourName: string;
    emailAddress: string;
    interest: InterestOptions;
    additionalInfo: string;
  };

  const templateParams: EmailTemplateProps = {
    projectName: "",
    yourName: "",
    emailAddress: "",
    interest: {
      integratingProject: false,
      hostingMission: false,
      airdroppingAssets: false,
      brandedAccessories: false,
    },
    additionalInfo: "",
  };

  const toggleChecked = (item: keyof InterestOptions) => {
    templateParams.interest[item] = !templateParams.interest[item];
  };

  function convertInterestsToEmailjsTemplate(template: EmailTemplateProps) {
    var interests = "";
    for (var key in template.interest) {
      if (template.interest[key]) {
        interests += key + ", ";
      }
    }
    return {
      projectName: template.projectName,
      yourName: template.yourName,
      emailAddress: template.emailAddress,
      interest: interests,
      additionalInfo: template.additionalInfo,
    };
  }
</script>

<div class="container">
  <h3>PARTNERSHIP ENQUIRIES</h3>
  {#if formSubmitted}
    <p>Form submitted! We'll be in touch soon.</p>
  {:else}
    <form on:submit|preventDefault={handleSubmit}>
      <label for="project-name">Project Name</label>
      <input bind:value={templateParams.projectName} id="project-name" type="text" placeholder="Project Name" required />
      <label for="your-name">Your Name</label>
      <input bind:value={templateParams.yourName} id="your-name" type="text" placeholder="Your Name" required />
      <label for="email">Email Address</label>
      <input bind:value={templateParams.emailAddress} id="email" type="email" placeholder="Email address" required />
      <label for="interests">Interest(s)</label>
      <Checkbox bind:checked={templateParams.interest.hostingMission} label="Hosting a mission (Let our Squad discover your platform)" />
      <Checkbox bind:checked={templateParams.interest.integratingProject} label="Integrating with our project (Ongoing activity boost)" />
      <Checkbox bind:checked={templateParams.interest.brandedAccessories} label="Branded Accessories (Digital merchandise)" />
      <Checkbox bind:checked={templateParams.interest.airdroppingAssets} label="Airdropping assets to our holders (Contest)" />

      <label for="additional">Additional Inforomation (Optional)</label>
      <textarea bind:value={templateParams.additionalInfo} id="additional" rows="4" placeholder="Additional information" />

      <button type="submit"> SUBMIT → </button>
    </form>
  {/if}
</div>

<style lang="scss">
  @use "../../styles" as *;

  .container {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding-bottom: 100px;
  }

  form {
    width: 600px;
    max-width: 100%;
  }

  label {
    display: block;
    text-transform: uppercase;
    font-weight: bold;
    margin-top: 20px;
    margin-bottom: 6px;
  }

  input,
  textarea {
    width: 100%;
    padding: 10px;
    border: 3px solid $white;
    background-color: transparent;
    color: $white;
    border-radius: 10px;
  }

  button {
    background-color: $yellow;
    color: $black;
    margin-top: 20px;
    width: 100%;
    max-width: 100%;
  }
</style>
