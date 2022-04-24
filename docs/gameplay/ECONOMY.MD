# **ICP Squad : economy**

The goal of this paper is to create a summary of all aspects of the ICP Squad economy so we can take the right decision to bring the economy as close as what we are targetting as possible, in the end the market will decide but good decision will reinforce the possibility of a positive outcome.

## **Overview** 👀

One of the main goal for all members of the squad should be to accumulate as much accessories as possible.
<br/> Accessories will give special bonus, passive income and can be seen as the speculative aspect of the game.
Accessories can only be created using materials (see recipes) and paying the minting fee or airdropped.

## **Accessories** 🧢

The accessories are divided into 5 categories depending on the slot they equip.

- Face 👦
- Hat 🎩
- Eyes 👀
- Body 👤
- Misc (Background, jewelry, discussion bubble..) 🌈

💡 Each accessory take only one slot. Multi-slot accessories have been discussed at one point, but they are not possible to implement with the current source code.

Once the gampeplay will be activated : for each day an accessory is equipped, it's wear value will be decreased by one; once it reachs 0 the accessory is automatically burned and desequipped from the avatar.
New accessories are minted with a wear value of 100.

## Bonus provided by accessories :

- Passive income when equipped (from the neuron).
- Increase bonus and points from both missions and other applications.
- Give access to special features and missions (To determine).

🤔 I think that our accessories should provite more benefits.

## **Materials** 🧱

Materials are the starting point of our economy, they are used to create accessories.

<table>
  <tr>
    <th> Name </th>
    <th> Picture </th>
    <th> Rarity </th>
    <th> Supply </th>
    <th> Rarity index </th>
  </tr>
  <tr>
    <td> Cloth </td>
    <td> <img src="../../assets/cards/materials/cloth.svg" width="150px" height="auto"> </img> </td>
    <td> 1/5</td>
    <td> 48 %</td>
    <td> 1  </td>
  </tr>
  <tr>
    <td> Wood </td>
    <td><img src="../../assets/cards/materials/wood.svg" width="150px" height="auto"> </img> </td>
    <td> 2/5</td>
    <td> 24 %</td>
    <td> 2  </td>
  </tr>
   <tr>
    <td> Glass </td>
    <td><img src="../../assets/cards/materials/glass.svg" width="150px" height="auto"> </img> </td>
    <td> 3/5</td>
    <td> 12 %</td>
    <td> 4 </td>
  </tr>
   <tr>
    <td> Metal </td>
    <td><img src="../../assets/cards/materials/metal.svg" width="150px" height="auto"> </img> </td>
    <td> 3/5</td>
    <td> 12 %</td>
    <td> 4  </td>
  </tr>
   <tr>
    <td> Circuit </td>
    <td><img src="../../assets/cards/materials/circuit.svg" width="150px" height="auto"> </img> </td>
    <td> 4/5</td>
    <td> 3 %</td>
    <td> 16  </td>

  </tr>
   <tr>
    <td> Dfinity-stone </td>
    <td><img src="../../assets/cards/materials/dfinity-stone.svg" width="150px" height="auto"> </img></td>
    <td> 5/5 </td>
    <td> 1 %</td>
    <td> 48 </td>

  </tr>
   <tr>
    <td> Cronic-essence </td>
    <td> <img src="../../assets/cards/materials/cronic-essence.svg" width="150px" height="auto"> </img> </td>
    <td> 5/5 </td>
    <td> Unkown </td>
    <td> ? </td>
  </tr>
   <tr>
    <td> Punk-essence </td>
    <td> <img src="../../assets/cards/materials/punk-essence.svg" width="150px" height="auto"> </img> </td>
    <td> 5/5 </td>
    <td> Unkown </td>
    <td> ?</td>
  </tr>
</table>

## **Star system & rarity index** ✨

Each material has a rarity index associated with it, this index in inversely proportional to the supply percentage of that materials among all other materials.

Each accessory has a rarity index associated with it, the rarity index is calculated using the recipe, by summing all the rarity indexs of the materials used to create the accessory.

For instance : to create **Lab-glasses** you need **3** cloth, **2** wood and **1** metal. <br/>
The rarity index of **Lab-glasses** is : 3 x 1 + 2 x 2 + 1 x 4 = **11**.

Each range of rarity index corresponds to a number of starts. <br/>
The start system will determine the bonus given by the accessory.

<table>
  <tr>
    <th> Star ⭐️ </th>
    <th> Rarity index 🔢</th>
  </tr>
  <tr>
    <th> 1  </th>
    <th> 0 - 9 </th>
  </tr>
  <tr>
    <th> 2  </th>
    <th> 10 - 19 </th>
  </tr>
  <tr>
    <th> 3  </th>
    <th> 20 - 29 </th>
  </tr>
  <tr>
    <th> 4  </th>
    <th> 30 - 50</th>
  </tr>
  <tr>
    <th> 5  </th>
    <th> 50 +</th>
  </tr>
</table>

## **Recipe** 🧪

Acessories can be minted following a recipe : combining some materials and paying the minting fee.
Some accessories have fixed supply, others have a rarity index that depends on the materials needed to create them.

The number of accessories in circulation will be greatly dependent on the number of materials airdropped monthly.

### <u> **Traditional** </u>

<table>
  <tr>
    <th>Slot</th>
    <th>Name</th>
    <th>Picture</th>
    <th>Recipe</th>
    <th>Rarity (expected) </th>
    <th>Live</th>
    <th>Rarity (index) </th>
  </tr>
  <tr>
    <td> Eyes 👀 </td>
    <td> Lab-glasses</td>
    <td> <img src="../../assets/cards/accessories/eyes/lab-glasses/lab-glasses-card.svg" width="150px" height="auto"> </img> </td>
    <td> Cloth : 3 <br/> Glass : 2 <br/> Metal : 1 </td>
    <td> 2/5</td>
    <td> Yes </td>
    <td> 11 </td>
   </tr>
  <tr>
    <td> Eyes 👀 </td>
    <td> Monocle </td>
    <td> <img src="../../assets/cards/accessories/eyes/monocle/monocle-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 2 <br/> Metal : 2 <br/> Glass : 3 </td>
    <td> 3/5</td>
    <td> Yes </td>
    <td> 22  </td>
  </tr>
  <tr>
    <td> Eyes 👀 </td>
    <td> Sunglasses </td>
    <td> <img src="../../assets/cards/accessories/eyes/sunglasses/sunglasses-card.svg" width="150" height="auto"> </img> </td>
    <td> <br/> Glass : 2 <br/> Metal : 1 </br> Circuit : 1 </td>
    <td> 3/5</td>
    <td> Yes </td>
    <td> 28 </td>

  </tr>
  <tr>
    <td> Eyes 👀 </td>
    <td> Dfinity-eyemask</td>
    <td> <img src="../../assets/cards/accessories/eyes/dfinity-eyemask/dfinity-eyemask-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 3 <br/> Wood : 2 <br/> Dfinity-stone : 1 </td>
    <td> 5/5</td>
    <td> Yes </td>
    <td> 51 </td>
  </tr>
  <tr>
    <td> Hat 🎩 </td>
    <td> Helicap </td>
    <td> <img src="../../assets/cards/accessories/hat/helicap/helicap-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 4 <br/> Wood : 3  </td>
    <td> 2/5</td>
    <td> Yes </td>
    <td> 10 </td>
  </tr>
  <tr>
    <td> Hat 🎩 </td>
    <td> Marshall-hat </td>
    <td> <img src="../../assets/cards/accessories/hat/marshall-hat/marshall-hat-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 3 <br/> Metal : 3  </td>
    <td> 3/5</td>
    <td> Yes </td>
    <td> 15 </td>
  </tr>
  <tr>
    <td> Hat 🎩 </td>
    <td> Assassin-hood </td>
    <td> <img src="../../assets/cards/accessories/hat/assassin-hood/assassin-hood-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 4 <br/> Metal : 4 <br/> 
    <td> 3/5</td>
    <td> No </td>
    <td> 20 </td>
  </tr>
  <tr>
    <td> Hat 🎩 </td>
    <td> Ninja-headband </td>
    <td> <img src="../../assets/cards/accessories/hat/ninja-headband/ninja-headband-card.svg" width="150" height="auto"> </img> </td>
    <td> Wood : 3 <br/>  Glass : 1 <br> Metal : 3 </td>
    <td> 3/5</td>
    <td> Yes </td>
    <td> 22 </td>
  </tr>
  <tr>
    <td> Hat 🎩 </td>
    <td> Shinobi-hat </td>
    <td> <img src="../../assets/cards/accessories/hat/shinobi-hat/shinobi-hat-card.svg" width="150" height="auto"> </img> </td>
    <td>  Wood : 5 <br/> Metal : 5 </td>
    <td> 4/5</td>
    <td> No </td>
    <td> 30 </td>
  </tr>
  <tr>
    <td> Hat 🎩 </td>
    <td> Magic-hood </td>
    <td> <img src="../../assets/cards/accessories/hat/magic-hood/magic-hood-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 1 <br/> Metal : 8  <br/> Dfinity-stone : 1 </td>
    <td> 5/5</td>
    <td> No </td>
    <td> 81 </td>
  </tr>
  <tr>
    <td> Hat 🎩 </td>
    <td> Astro-helmet </td>
    <td> <img src="../../assets/cards/accessories/hat/astro-helmet/astro-helmet-card.svg" width="150" height="auto"> </img> </td>
    <td> Glass : 2 <br/> Metal : 3 <br/> Circuit : 2 <br/> Dfinity-stone : 1 </td>
    <td> 5/5</td>
    <td> No </td>
    <td> 100 </td>
  </tr>
  <tr>
    <td> Face 👦 </td>
    <td> Oni-face-mask </td>
    <td> <img src="../../assets/cards/accessories/face/oni-face-mask/oni-face-mask-card.svg" width="150" height="auto"> </img> </td>
    <td> Wood : 4 <br/> Metal : 4 </td>
    <td> 3/5</td>
    <td> Yes </td>
    <td> 100 </td>
  </tr>
  <tr>
    <td> Face 👦 </td>
    <td> Facemask </td>
    <td> <img src="../../assets/cards/accessories/face/facemask/facemask-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 4 <br/> Metal : 6 </td>
    <td> 3/5</td>
    <td> Yes </td>
    <td> 28 </td>
  </tr>
  <tr>
    <td> Body 👤 </td>
    <td> Helicap-tshirt </td>
    <td> <img src="../../assets/cards/accessories/body/helicap-tshirt/helicap-tshirt-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 4 <br/> Wood : 4 </td>
    <td> 2/5</td>
    <td> No </td>
    <td> 12 </td>
  </tr>
  <tr>
    <td> Body 👤 </td>
    <td> Assassin-cap </td>
    <td> <img src="../../assets/cards/accessories/body/assassin-cap/assassin-cap-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 4 <br/> Glass : 3 <br/> Metal : 2 </td>
    <td> 3/5</td>
    <td> No </td>
    <td> 24 </td>
  </tr>
   <tr>
    <td> Body 👤 </td>
    <td> Yakuza-suit </td>
    <td> <img src="../../assets/cards/accessories/body/yakuza-suit/yakuza-suit-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 2 <br/> Glass : 3 <br/> Metal : 3 </td>
    <td> 3/5</td>
    <td> No </td>
    <td> 26 </td>
  </tr>
  <tr>
    <td> Body 👤 </td>
    <td> Lab-coat </td>
    <td> <img src="../../assets/cards/accessories/body/lab-coat/lab-coat-card.svg" width="150" height="auto"> </img> </td>
    <td> Glass : 3  <br/> Circuit : 1 </td>
    <td> 3/5</td>
    <td> No </td>
    <td> 28 </td>
  </tr>
  <tr>
    <td> Body 👤 </td>
    <td> Shinobi-suit </td>
    <td> <img src="../../assets/cards/accessories/body/shinobi-suit/shinobi-suit-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 2 <br/> Wood : 2 <br/> Metal : 3 <br/> Circuit : 1  </td>
    <td> 4/5</td>
    <td> No </td>
    <td> 32 </td>
  </tr>
  <tr>
    <td> Body 👤 </td>
    <td> Devil-jacket </td>
    <td> <img src="../../assets/cards/accessories/body/devil-jacket/devil-jacket-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 6 <br/> Wood : 6 <br/> Metal : 6 <br/>  </td>
    <td> 4/5</td>
    <td> No </td>
    <td> 42 </td>
  </tr>
  <tr>
    <td> Body 👤 </td>
    <td> Street-jacket </td>
    <td> <img src="../../assets/cards/accessories/body/street-jacket/street-jacket-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 7 <br/> Glass : 1 </br> Circuit : 2 </td>
    <td> 4/5 </td>
    <td> No </td>
    <td> 43 </td>
  </tr>
  <tr>
    <td> Body 👤 </td>
    <td> Magic-cap </td>
    <td> <img src="../../assets/cards/accessories/body/magic-cap/magic-cap-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 9 <br/> Dfinity-stone : 1 </td>
    <td> 5/5</td>
    <td> No </td>
    <td> 57 </td>
  </tr>
  <tr>
    <td> Body 👤 </td>
    <td> Astro-suit </td>
    <td> <img src="../../assets/cards/accessories/body/astro-suit/astro-suit-card.svg" width="150" height="auto"> </img> </td>
    <td> Metal : 4 <br/> Glass : 3 <br/> Circuit : 2 <br/> Dfinity-stone : 1 </td>
    <td> 5/5</td>
    <td> No </td>
    <td> 98 </td>
  </tr>
  <tr>
    <td> Misc 🌈 </td>
    <td> Snowfall </td>
    <td> <img src="../../assets/cards/accessories/misc/snowfall/snowfall-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 9 <br/> Dfinity-stone : 1 </td>
    <td> 5/5</td>
    <td> No </td>
    <td> 57 </td>
  </tr>
  <tr>
    <td> Misc 🌈 </td>
    <td> Sunrise </td>
    <td> <img src="../../assets/cards/accessories/misc/sunrise/sunrise-card.svg" width="150" height="auto"> </img> </td>
    <td> Cloth : 9 <br/> Dfinity-stone : 1 </td>
    <td> 5/5</td>
    <td> No </td>
    <td> 57 </td>
  </tr>
  
</table>

### <u> **Limited edition** </u>

<table>
  <tr>
    <th>Slot</th>
    <th>Name</th>
    <th>Picture</th>
    <th>Recipe</th>
    <th> Partnership </th>
    <th>Live</th>
    <th> Supply </th>
  </tr>
  <tr>
    <td> Hat 🎩 </td>
    <td> Mortaboard-hat </td>
    <td> <img src="../../assets/cards/accessories/hat/mortaboard-hat/mortaboard-hat-card.svg" width="150px" height="auto"> </img> </td>
    <td> Airdropped. </td>
    <td> Motoko-bootcamp </td>
    <td> No </td>
    <td> ? </td>
  </tr>
  <tr>
    <td> Body 👤 </td>
    <td> Bootcamp-solider </td>
    <td> <img src="../../assets/cards/accessories/body/bootcamp-soldier/bootcamp-soldier-card.svg" width="150px" height="auto"> </img> </td>
    <td> Airdropped. </td>
    <td> Motoko-bootcamp </td>
    <td> No </td>
    <td> ? </td>
  </tr>
  <tr>
    <td> Body 👤 </td>
    <td> Cronic-tshirt </td>
    <td> <img src="../../assets/cards/accessories/body/cronic-tshirt/cronic-tshirt-card.svg" width="150px" height="auto"> </img> </td>
    <td> ? </td>
    <td> Cronic </td>
    <td> No </td>
    <td> Limited </td>
  </tr>
  <tr>
    <td> Eyes 👀 </td>
    <td> Cronic-eyepatch </td>
    <td> <img src="../../assets/cards/accessories/eyes/cronic-eyepatch/cronic-eyepatch-card.svg" width="150px" height="auto"> </img> </td>
    <td> ? </td>
    <td> Cronic </td>
    <td> No </td>
    <td> Limited </td>
  </tr>
    <tr>
    <td> Misc 🌈</td>
    <td> Cronic-hypnose </td>
    <td> <img src="../../assets/cards/accessories/misc/cronic-hypnose/cronic-hypnose-card.svg" width="150px" height="auto"> </img> </td>
    <td> ? </td>
    <td> Cronic </td>
    <td> No </td>
    <td> Limited </td>
  </tr>
    <tr>
    <td> Misc 🌈 </td>
    <td> Cronic-wallpaper </td>
    <td> <img src="../../assets/cards/accessories/misc/cronic-wallpaper/cronic-wallpaper-card.svg" width="150px" height="auto"> </img> </td>
    <td> ? </td>
    <td> Cronic </td>
    <td> No </td>
    <td> Limited </td>
  </tr>
  <tr>
    <td> Face 👦 </td>
    <td> Punk-mask </td>
    <td> <img src="../../assets/cards/accessories/face/punk-mask/punk-mask-card.svg" width="150px" height="auto"> </img> </td>
    <td> ? </td>
    <td> ICPunk </td>
    <td> No </td>
    <td> Limited </td>
  </tr>
  <tr>
    <td> Eyes 👀 </td>
    <td> Punk-glasses </td>
    <td> <img src="../../assets/cards/accessories/eyes/punk-glasses/punk-glasses-card.svg" width="150px" height="auto"> </img> </td>
    <td> ? </td>
    <td> ICPunk </td>
    <td> No </td>
    <td> Limited </td>
  </tr>

</table>

## Minting fee 💲

Before minting an accessory, a **minting fee** will be asked. <br/>
This fee has been voted on by the community to be initialized at **0.5 ICP**. <br/>
The fee will evolve to adjust the rate of accessories and can be used to adujst our economy when needed to avoir hyper-inflation of accessories.

## ICP Squad neuron 🧠

An 8-years locked neuron.

**How do we fund it ?**

- Minting fee
- Legendary accessories sale.
- Other : mission fee ?

**How do we harvest it and how do we distribute rewards ?**

- Harvested every month / every week ?
- Rewards put in a pool that is distributed to all accessory holders ?
- Passive rewards only ?

**How is it governed ?**

We currently don't have a governance framework, we will probably follow a known actor of the NNS (Dfinity foundation/ ICA / Maximalist network) until we developed our own governance board (as discussed with missions/motoko bootcamp).

## Passive income

Every month/week/day ?

Passive income for accessory holders only ?
Prize pool coming from the neuron harvested rewards.

How much ?
Depends on number of starts + random factor.

## Active income

Every month

- Missions : ICP Squad or others : quizz/tasks.
- Application score : DSCVR/Gigaverse Labs/Cronic

Prize pool : materials and accessories only ?

## Targets 🎯

- Low barrier to entry : this project aims to promote engagement on the Internet Computer to outside persons and should stay accessible to anyone who wants to support the ecosystem.

  - Avatar minting should remain at low price : **1 ICP**.
  - Accessories/materials should remain at low entry as well, especially for the most commons one so that everyone can get a chance and try out some accessories.

- Fair rewards to strategic contributors : early contributors, heavy and curious IC users and invested users deserve advantages in our game. <br/> However bots, insiders and whales should never be able to ruin the fun for everyone else and take all the rewards for themselves.

  - Fixed cap between the "lowest ranked player" and the "highest ranked player".
  - Protection against bots and penalty for suspicious behaviours.
  - Legendary accessories : a way for whales to get involved without ruining the rest of the economy.

- Long term market stability : TODO

## Max advantage ✋

- Lowest ranked player : This player is the
- Highest ranked player : Maximum score + accessory boost combined.

The potential chance of rewards between the lowest ranked player and the highest ranked player will never be above 200x. <br/> This might seems a lot but it represents the maximum gap between the **most** active player and the **less** active one; also taking into account eventual accessories boosts.

- Action gap : scores & missions.

The action gap represents the maximum increase in chance of getting rewards that one can reach by maximizing it's scores in all dapps and completing a maximum number of mission this month. <br/>

The action gap is 20x. This means you can give yourself an up to 20x higher chance of winning a reward vs the lowest active player.

- Boost gap : accessories.

The boost gap represents the maximum increase in chance of getting rewards that one can reach trough maximizing accessories bonus.

This boost gap is 10x. This means a fully equipped player can get up to 10x higher chance of winning a reward vs a non-equipped player.

## Legendary accessories 🧙

Legendary auctions will be held to get your hands on the **legendary accessories** that **never** wear out !

Here are some benefits of holding legenday accessories :

- They never wear out, which guarantees continous rewards from ICP Squad Neuron as well as a boost for additional engage-to-earn rewards.
- They will be **extremly rare** with less than 400 minted each year, it will take at least 12.5 years to reach a supply of 5000.
- Membership perks for the DAO to come such as private DSCVR portal.
- In the future we plan to enable features that will you safely rent / lend your accessories to other users for passive income while keeping them in your wallet; legendary accessories will be the most valuable assets to borrow.

Legendary auctions : TODO
