
    
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
        @tournamentWins = ko.observable()
        console.log @players()
        
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
                        tournaments_won: player.tournaments_won
                        matches_played: ko.observable(player.matches_played())
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
                        tournaments_won: player.tournaments_won
                        matches_played: ko.observable(player.matches_played())
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
                        tournaments_won: player.tournaments_won
                        matches_played: ko.observable(player.matches_played())
                    }
                    if player.wins() == 3
                        @champion(newPlayer.name)
                        player.wins("Winner!")
                        @writeTournamentsWon(newPlayer)
                        @champion(@champion())    
       

    # Increments win count. Adds wins to players matches_played DB which we use as total wins
    increment: (player) =>
        player.wins(player.wins() + 1)
        player.matches_played(player.matches_played() + 1)
        @writeGamesWon(player)
        console.log "Player: ", player.name
        console.log "Wins: ", player.matches_played()
      
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
                    item.matches_played = ko.observable(item.matches_played)
                    @players().push(item)
                    @players(@players())
            , (err) => 
                console.log err
            )

    writeGamesWon: (player) =>
        horizon = Horizon()
        horizon.connect()
        players = horizon("players")
        newVal = player.matches_played() + 1

        players.update({
            id: player.id
            matches_played: newVal
        })

    writeTournamentsWon: (player) =>
        horizon = Horizon()
        horizon.connect()
        players = horizon("players")
        newVal = player.tournaments_won + 1

        players.update({
            id: player.id
            tournaments_won: newVal
        })


ko.applyBindings new App()