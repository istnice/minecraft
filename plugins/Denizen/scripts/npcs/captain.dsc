captain_assi:
    type: assignment
    debug: false
    actions:
        on assignment:
        - trigger name:click state:true
        on spawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> start fake
        on despawn:
        - sneak <list[<npc>].include[<npc.name_hologram_npc||<list>>].include[<npc.hologram_npcs||<list>>]> stopfake
        on click:
        - cooldown 10

        # test effect

        - define timeout <util.random.int[1].to[3]>
        - define pid <npc.flag[pid]>
        - define partner <npc[<[pid]>]>
        - random:
          - chat "Unser nächstes Ziel: <&b><npc.flag[ziel]><&f>. Wir legen in kürze ab."
          - chat "Dieses Schiff fährt gleich nach <&b><npc.flag[ziel]><&f>."
          - chat "Begleite mich doch. Ich segel jeden Augenblick los. Mein Ziel: <&b><npc.flag[ziel]><&f>."
        - wait <[timeout]>
        - random:
          - chat "Wer nicht mitfahren will, sollte jetzt das Schiff verlassen. Alle anderen zu mir!"
          - chat "Verlasst das Schiff, wenn ihr hier bleiben wollt."
          - chat "Fährst du mit? Dann komm. Sonst verzieh dich!"
          - chat "Gesellt euch zu mir, wenn ihr mit fahren wollt."
        - wait <[timeout]>
        - random:
          - chat "Und los gehts!"
          - chat "Leinen los!"
          - chat "Ab geht die Fahrt."
          - chat "Alle Mann an Board!"
          - chat "Hisst die Segel!"
        # blind and port
        - define port_players <npc.location.find.players.within[5]>
        - foreach <npc.location.find.players.within[5]> as:player:
          - define effects <player.list_effects>
          # TODO: perfekt schwarz haengt von tages zeit ab (individuelle spielerzeit setzen?)
          # - adjust <[player]> potion_effects:<player.list_effects.include[EFFECT,AMPLIFY,DURATION,IS_AMBIENT,HAS_PARTICLES,HAS_ICON]>
          # - adjust <[player]> potion_effects:<player.list_effects.include[NIGHT_VISION,255,120,true,true,false]>
          # - adjust <[player]> potion_effects:<player.list_effects.include[BLINDNESS,255,120,true,true,false]>
          - adjust <[player]> potion_effects:<list[BLINDNESS,255,120,false,true,false|NIGHT_VISION,255,120,false,true,false]>
          # - adjust <[player]> potion_effects:<list[NIGHT_VISION,255,120,true,true,false]>
        - wait 2
        - foreach <npc.location.find.players.within[5]> as:player:
          - teleport <[player]> <[partner].location.add[1,0,0]>
        - wait 1
        - random:
          - narrate "Und wir sind da.."
          - narrate "Ich hoffe Ihr hattet eine angenehme Reise."
          - narrate "Na das lief doch gut. Wir sind da."
          - narrate "Das hier ist: <npc.flag[ziel]>"


captain_cmd:
    type: command
    debug: false
    name: npccaptain
    usage: /npccaptain pid [ID]
    description: Mache einen NPC zum Captain. Erfordert constanten pid (partner id) und ziel (name wo es hingeht).
    permission: script.npccaptain
    script:
    - if !<list[pid|ziel|off].contains[<context.args.get[1]||null>]>:
        - narrate "<&c>/npccaptain off - Kein Captain mehr."
        - narrate "<&c>/npccaptain ziel [NAME] - Reiseziel für Dialog"
        - narrate "<&c>/npccaptain pid [ID] - ID des Partners/Klons"
        - stop
    - if <player.selected_npc||null> == null:
        - narrate "<&c>Kein NPC ausgewählt! /npc sel"
        - stop
    - if <context.args.get[1]> == off:
        - if <npc.script.name||null> != npc_captain_assignment:
            - narrate "<&c>NPC ist kein Captain."
            - stop
        - assignment remove
        - flag <npc> ziel:!
        - flag <npc> pid:!
        - narrate "<&a>NPC ist jetzt kein Captain mehr."
        - stop
    - assignment set script:npc_captain_assignment npc:<player.selected_npc>
    - if <context.args.get[1]> == pid:
        - flag <player.selected_npc> pid:<context.raw_args.after[pid].trim>
        - narrate "<&a>Mit Klon verlinkt."
    - if <context.args.get[1]> == ziel:
        - flag <player.selected_npc> ziel:<context.raw_args.after[ziel].trim>
        - narrate "<&a>Zielname geändert."
