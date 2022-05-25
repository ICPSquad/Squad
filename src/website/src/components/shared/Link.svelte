<script>
  import { Link } from "svelte-routing";

  export let to;
</script>

<Link style="width: 100%; display: flex; justify-content: center" {to}>
  <slot />
</Link>
