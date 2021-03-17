general_events:
    type: world
    debug: false
    events:
        #| SPIELER STIRBT
        on player death:
        # TODO: drop playerhead depending on cause?
        - narrate "Du bist tot"
        # Head drop at 10% chance
        - if <util.random.int[1].to[10]> == 1:
            - define head_name "<player.name>s Kopf"
            - define head player_head[skull_skin=<player.name>;display_name=<[head_name]>]
            - drop <[head]> <player.location>
        - determine passively NO_DROPS
        - determine passively NO_XP
        - determine passively KEEP_LEVEL
        - determine KEEP_INV

        #| SPIELER SPAWNT
        on player respawns:
        - narrate "Du lebst wieder"

        #| RELOAD SCRIPTS
        # on script reload:
        # TODO: check exclusions (move the lines where they belong)
        # - foreach <server.npcs> as:npc:
        #     - sneak <[npc]> fake

        # on time changes in world:
        # - announce "<gray>Es ist <context.time> Uhr!"
