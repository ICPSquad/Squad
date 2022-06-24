// This code was run once to mint all the rewards from the bootcamp
import { accessoriesActor } from "../../actor";
import { fetchIdentity } from "../../keys";
import { Principal } from "@dfinity/principal";

const students = [
  "yeen2-dedgk-qpliz-g2hrs-gke3w-tntv3-m7any-ff2r2-bsmx7-opvin-hae",
  "frr2p-iyhp3-ioffo-ysh2e-babmd-f6gyf-slb4h-whtia-5kg2n-5ix4u-dae",
  "rwvq4-ggic3-l2cjc-rh4k4-fcef7-wjic7-h4qka-anlb2-3c4k3-vakcv-jae",
  "qgcnp-i5ptu-cdoew-yxuoz-3qgnq-yf5m2-6joaf-luxe5-xanvv-kaqqd-uae",
  "o7hro-3wo4c-msply-er53g-6f2ti-swcdz-ig7my-ognsq-5wpeb-sujyz-uae",
  "pksn4-amd7s-fbiqx-qql5y-dz625-cxhpv-jsguj-b6h3z-5wlb2-b5ho4-nae",
  "qdahs-v2iah-yi7wp-mb2re-ralpv-w7jc2-73s3r-az57r-nbs6o-qvzd2-lae",
  "cigaa-5edaj-kz4bp-q7vhc-svlse-i6hcj-ezjvw-6pazk-egark-a3vyb-hqe",
  "fcbig-t4n42-nsog6-vtig7-jd4ee-mad63-mo7yi-ugbwq-2nmxd-hwubr-tae",
  "ln6ua-727g6-o3te3-skjkt-w3ttv-3lvfo-z4sqn-26zji-lxnyq-hwysz-kae",
  "wib6c-xgdhw-esjka-jnhy4-crmap-falii-jmdq5-iupvk-lwd3f-r23xo-nqe",
  "hhrey-ownwx-arrfr-hsr3l-qr566-qzdzo-2xn2l-q5amz-qetzm-3zjvn-tae",
  "vfkkj-zurs7-dnnw5-dn2tt-qa7wx-wmcov-jj7zw-wv2zy-eolie-e3xhh-nqe",
  "mlvdq-eg2nv-zsiyw-gc5yk-mvwsn-wd3m6-a2d2i-tf2lf-xbpvu-yhfzb-sqe",
  "iachr-jcgtt-l3hgv-e6bek-k3uw3-czsry-7s7sv-sde5j-eeu6b-dlgli-gqe",
  "faegv-6aqhz-da23y-wlvcg-fsiff-yyi3t-dwipk-i2fms-xgool-7jkwq-oqe",
  "aoqra-vdgic-4jm4k-6tiio-3gx2i-hy3r5-g5hpl-i2rep-irsdu-tegbu-xqe",
  "b2k2j-pss6c-2zwqf-67gxm-txdab-qvmz3-jhaxw-psiyj-nvxha-57dpu-sae",
  "qcbdd-ljwgi-duwep-w6lyt-yvql7-wpomw-ybdbn-i2eol-qs4em-chngv-sae",
  "h6a6a-ffvll-4y3hv-2v7bh-mgso7-h4vsb-aldfe-amckr-zu3ts-e56xg-mae",
  "aw5x5-rjc4g-qm45s-bq4ey-bdbs7-w35ar-daqxk-vmm6f-7arz5-n5hwq-mqe",
  "zz7io-xsv2f-e2vup-pwazj-jgpxz-7m2i7-mqc4x-ocaxx-ayaj2-xcc7c-xae",
  "ut5ul-eij6p-oxjq7-je3gj-ctqwd-nlvs3-vqdwd-au3hu-6pqeg-gfkxz-uae",
  "5qx44-f2bjq-reh3x-krg4f-frwwe-2hm25-mm2rw-wtdd6-6dvb2-ejegr-zqe",
  "v74r3-fv2ks-kth23-h2pwj-iip23-djcqx-2xin3-i6hjc-q3cub-ddxgi-rqe",
  "lztxj-vebzh-qyml2-uqriq-7mt2b-vrllu-jt7ex-tvkb3-ygxyd-aglt6-xae",
  "bd7t4-kdq4g-b7ndv-droxn-77pf6-4i76v-xvhls-zqmz2-zawky-shroo-hae",
  "wm7id-n5krh-y4vek-id6h6-7euvv-n35sv-ar5el-mf5bb-t7nz3-tdd5p-eae",
  "tyvr4-pols6-lvf2i-j5cp3-k5zs4-gmsp4-r2pvr-teogk-hj3jg-issib-yqe",
  "7pw2f-dpza4-65jux-nrqai-2msy4-bleyo-wqqie-u5bnd-cnzbg-ho7d5-3ae",
  "rtxym-zhtkz-ct2if-7of7e-s5d2o-orynn-e46kx-huojz-bhuxx-bxqd7-pqe",
  "m46xq-bfdxz-u3a6n-wr7cc-gmpq4-fhko6-kkqfr-citqj-vp5og-fbxbe-nqe",
  "blxqm-3jbqd-64f37-rwttn-bxovv-btwom-mgk4v-dzqqw-rc2wb-hlfke-oqe",
  "674vh-do5e5-4j2mx-uuuvv-tqsgy-3g3uh-2bj7r-ifxq6-fcun2-bomyz-iae",
  "lhu5k-yxcii-4lug3-e7caz-xv72o-3w7ri-mlqfu-xc2e3-h57be-42nt7-6qe",
  "2sc42-v45cm-g5ev3-pqtaj-hllct-d64no-3hpcz-sq6ub-mwcep-4na42-rae",
  "hxdpn-hxyoy-em7uq-73yoz-fcese-vwdzn-fcdtu-p746p-e3fkm-rxnhk-cqe",
  "venvc-pbsd4-4ti6q-p5bnv-ogxz6-yzvz3-kczqe-qcbuy-a5l5w-7pdlb-vae",
  "6u46j-wwsdl-cadcn-guatw-4jz6h-uoqtl-2gnlr-zxd54-m633p-ox4xy-4ae",
  "lkevu-etzuu-qh7yq-javga-err63-apw7h-2ndl3-lbs6s-3wani-2uj36-xae",
];

async function mint(): Promise<void> {
  const identity = fetchIdentity("admin");
  const accessories = accessoriesActor(identity);
  const length = students.length;
  for (let i = 0; i < length; i++) {
    const principal = students[i];
    const result = await accessories.mint("Mortaboard-hat", Principal.fromText(principal));
    console.log(result);
  }
}

mint();
