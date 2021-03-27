bettler_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - trigger name:proximity state:true radius:3
        - sneak <npc> start
        # - define skinurl https://www.minecraftskins.com/uploads/skins/2020/12/23/beggar-16138813.png?v302
        - define skin_blob <server.flag[npc_skins.bettler]||null>
        - if skin_blob == null:
            - narrate "<red>Kein Skin namens bettler gefunden:"
        - else:
            - adjust <npc> skin_blob:<server.flag[npc_skins.bettler]>
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
        on enter proximity:
        # - cooldown 300
        - playsound <player> sound:ENTITY_VILLAGER_YES
        - random:
            - chat "Hey hast du vielleicht ein Bitgeld für einen armen alten Mann?"
            - chat "Bitte nur eine Münze für einen armen Mann."
            - chat "Seid so gut und helft mir mit ein bisschen Kleingeld."
        on move proximity:
        - walk <npc> <player.location>
        on click:
        - cooldown 300
        - if <player.flag[geld]> < 1:
            - narrate "<gray>Nicht genug Geld um dem Bettler etwas zu geben."
            - determine cancelled
        - flag <player> geld:<player.flag[geld].sub_int[1]>
        - narrate "<gray> Bettler <red>1<gray> Bitgeld gegeben."
        - random:
            - chat "Danke, Meister!"
            - chat "Seid gesegnet."
            - chat "vielen Dank."
        - if <util.random.int[1].to[100]> < 10:
            - playsound <player> sound:ENTITY_EXPERIENCE_ORB_PICKUP
            - narrate "<gray> Du fühlst dich glücklich."
            - flag <player> lucky:true duration:6000

