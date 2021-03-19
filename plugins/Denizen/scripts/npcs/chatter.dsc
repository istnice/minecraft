# +--------------------
# |
# | NPCCHATTER
# |
# | Modified version of mcmonkeys drop-in helper for making chatting NPCs.
# | Players can right-click the NPC at any time to see a message.
# |
# +----------------------

# ---------------------------- END HEADER ----------------------------

chatter_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        - sneak <npc> start fake
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
        # - vulnerable true
        on click:
        - define msg <npc.flag[message].random.parsed||null>
        - if <[msg]> == null:
            - narrate "<red>Kein Text!<gray> Dieser NPC ist ein Chatter ohne Nachrichten. Benutze <yellow>/npc sel<gray> und <yellow>/npcchatter add <white>[Nachricht]<gray> um eine Nachricht hinzuzufügen."
        - else:
            - chat <[msg]>
            - playsound <player> sound:ENTITY_VILLAGER_YES

chatter_cmd:
    type: command
    debug: false
    name: npcchatter
    usage: /npcchatter set [message]
    description: Makes an NPC be chatty!
    permission: script.npcchatter
    script:
    - if !<list[create|set|add|off].contains[<context.args.get[1]||null>]>:
        - narrate <gray>-----------------------------
        - narrate "<yellow>/npcchatter off"
        - narrate "  <gray>- Löscht den Chatterjob"
        - narrate "<yellow>/npcchatter create <white>[Name]"
        - narrate "  <gray>- Erstellt einen neuen NPC und macht ihn zum Chatter"
        - narrate "<yellow>/npcchatter set <white>[Nachricht]"
        - narrate "  <gray>- Setzt eine einzige Nachricht (andere werden gelöscht)"
        - narrate "<yellow>/npcchatter add <white>[Nachricht]"
        - narrate "  <gray>- Weitere Nachricht. Wählt zufällig aus allen aus."
        - narrate <gray>-----------------------------
        - stop

    - if <context.args.get[1]> == create:
        - define name <context.args.get[2]||null>
        - if <[name]> == null:
            - narrate "<red> Name fehlt: <yellow>/npcchatter create <red>[Name]"
            - stop
        - narrate "<gray>Neuen NPC als Chatter erstellen"
        - create player <[name]> <player.location> traits:lookclose save:npc

        - define npc <entry[npc].created_npc>
        - adjust <player> selected_npc:<[npc]>
        - define skin_blob <server.flag[npc_skins.chatter]||null>
        - if skin_blob == null:
            - narrate "<red>Kein Skin namens chatter gefunden:"
        - else:
            - adjust <[npc]> skin_blob:<server.flag[npc_skins.chatter]>
        - assignment set script:chatter_assi npc:<[npc]>
        - narrate "<gray>Chatter erstellt, ergänze nachrichten mit <yellow>/npcchatter add <white>[Nachricht]"
        - stop

    - if <player.selected_npc||null> == null:
        - narrate "<red>Kein NPC ausgewählt!"
        - stop
    - if <context.args.get[1]> == off:
        - if <npc.script.name||null> != chatter_assi:
            - narrate "<red>NPC ist kein Chatter."
            - stop
        - assignment remove
        - flag <npc> message:!
        - narrate "<green>NPC ist kein Chatter mehr."
        - stop


    # assign
    - assignment set script:chatter_assi npc:<player.selected_npc>

    # assigned commands
    - if <context.args.get[1]> == set:
        - flag <player.selected_npc> message:<context.raw_args.after[set].trim>
        - narrate "<green>Einzelne Nachricht gesetzt."
    - else if <context.args.get[1]> == add:
        - flag <player.selected_npc> message:->:<context.raw_args.after[add].trim>
        - narrate "<green>Nachricht hinzugefügt."



