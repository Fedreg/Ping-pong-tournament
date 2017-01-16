
    
class App
    constructor: ->
        @players = ko.observableArray([])
        @getPlayers()
        @roundNumber = ko.observable(1)
        @semiFinalists = ko.observableArray([])
        @finalists = ko.observableArray([])
        @champion = ko.observable()
        @positions = ko.observable(false)
        @gameStarted = ko.observable(false)
        
        # Determines round number.
        @whichRound = ko.computed =>
            if @semiFinalists().length == 4
                @roundNumber(2)
            if @finalists().length == 2
                @roundNumber(3)

        #If a player wins three games, he is pushed into the next round array.
        @winners = ko.computed =>
            if @roundNumber() == 1   
                for player in @players()
                    newPlayer = {
                        name: player.name
                        wins: ko.observable(0)
                        id: player.id
                    }
                    if player.wins() == 3
                        @semiFinalists().push(newPlayer)
                        player.wins("Winner!")
                        @semiFinalists(@semiFinalists())
            if @roundNumber() == 2 
                for player in @semiFinalists()
                    newPlayer = {
                        name: player.name
                        wins: ko.observable(0)
                        id: player.id
                    }
                    if player.wins() == 3
                        @finalists().push(newPlayer)
                        player.wins("Winner!")
                        @finalists(@finalists())      
            if @roundNumber() == 3
                for player in @finalists()
                    newPlayer = {
                        name: player.name
                        wins: ko.observable(0)
                        id: player.id
                    }
                    if player.wins() == 3
                        @champion(newPlayer.name)
                        player.wins("Winner!")
                        @writeGameStats(newPlayer)
                        @champion(@champion())    
       

    # Increments win count.
    increment: (player) =>
        player.wins(player.wins() + 1)

    # Shuffles players and displays brackets. Fisher-Yates 
    startTournament: =>
        arr = @players()
        i = arr.length
        while --i
            j = Math.floor(Math.random() * (i+1))
            tempi = arr[i]
            tempj = arr[j]
            arr[i] = tempj
            arr[j] = tempi
        @players(arr)
        @positions(true)
        @gameStarted(true)

    getPlayers: => 
        horizon = Horizon()
        horizon.connect()
        players = horizon("players")

        players.fetch().subscribe(
            (items) => 
                for item in items
                    item.wins = ko.observable(item.wins)
                    @players().push(item)
                    @players(@players())
                    console.log item
            , (err) => 
                console.log err
            )
        console.log "Players: ", @players()

    writeGameStats: (player) =>
        horizon = Horizon()
        horizon.connect()
        players = horizon("players")

        players.update({
            id: player.id
            tournaments_won: (parseInt(player.tournaments_won) + 1)
            })

    getAllTimeStats: =>


ko.applyBindings new App()