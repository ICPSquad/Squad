import { Principal } from "@dfinity/principal";
import {
  MintRequest,
  ExtCoreUser,
  AvatarRequest,
} from "declarations/event/event.did.d";
import { buildRequestFromAvatar } from "./avatar";
import store from "../store";

export function createMintRequest(): MintRequest | null {
  let principal = store.getters.getPrincipal;
  let user_ext: ExtCoreUser = buildExtCoreUserFromPrincipal(principal);
  let avatar = store.getters.getAvatar;
  let avatar_request_maybe: AvatarRequest | null =
    buildRequestFromAvatar(avatar);
  if (avatar_request_maybe === null) {
    return null;
  } else {
    let avatar_request = avatar_request_maybe as AvatarRequest;
    let mint_request: MintRequest = {
      to: user_ext,
      metadata: avatar_request,
    };
    return mint_request;
  }
}

function buildExtCoreUserFromPrincipal(p: Principal): ExtCoreUser {
  let user_ext: ExtCoreUser = {
    principal: p,
  };
  return user_ext;
}
