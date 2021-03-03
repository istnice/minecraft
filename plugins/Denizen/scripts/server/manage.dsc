manage:
    type: world
    events:
        on script reload:
        - yaml create id:pois
        - ~yaml load:pois.yml id:pois
        - define pois <yaml[pois].read[]>
        - define names <[pois].keys>
        - narrate <[names]>
        - yaml unload id:pois
        # - define msg ""
        # - foreach <[pois].keys> as:k:
        # - define msg "<[msg]> <[k]>"
        # - narrate <[msg]>
        # - narrate <[pois]>
        - flag server poinames:<[names]>