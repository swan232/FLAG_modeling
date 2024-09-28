function sub = makeGame_v1(sub, varargin)

if nargin > 1
    social = varargin{1}; 
else
    social = false;
end

for sn = 1:length(sub)
    % indices of choiceDown, e.g., 25, 38, 51, 64, ...
    i_choiceDown    = find(strcmp(sub(sn).type, 'choice_down'   )); 
    % indices of choiceOutcome, e.g., 26, 39, 52, 65, ...
    i_choiceOutcome = find(strcmp(sub(sn).type, 'choice_outcome'));
    % remove practice trials
    if ~social
        i_choiceDown = i_choiceDown(5:104);
    else
        i_choiceDown = i_choiceDown(5:100);

    end

    % disp(i_choiceDown)
    for g = 1:length(i_choiceDown)
        game(g).rt        = sub(sn).rt(i_choiceDown(g));
        % convert cell array to double if not formatted correctly
        if(iscell(game(g).rt))
            game(g).rt = str2double(game(g).rt);
        end
        
        game(g).choseDeck = strcmpi(sub(sn).choseDeck(i_choiceDown(g)), 'true'); % strcmpi: compare strings case insensitive
        
        game(g).key       = sub(sn).key_press(i_choiceDown(g));
        % key = 70 => f => left
        % key = 74 => j => right

        if(iscell(game(g).key))
            game(g).key = str2double(game(g).key);
        end
        
        game(g).choseLeft = game(g).key == 70;
        game(g).offer     = sub(sn).offer(i_choiceDown(g));
        game(g).side      = 2*sub(sn).side(i_choiceDown(g))-1;

        game(g).outcome   = sub(sn).reward_on_choice(i_choiceDown(g)+1);
        
        
        dum = regexp(sub(sn).card{i_choiceDown(g)}, '/|\.', 'split'); % {0×0 char}    {0×0 char}    {'img'}    {'card1'}    {'png'}
        game(g).card      = dum{end-1}; % 'card1'
        if i_choiceDown(g)-9 < 0
            game(g).rewards   = nan(5,1);
            game(g).rts       = nan(5,1);
        else
            game(g).rewards   = sub(sn).reward(i_choiceDown(g)-9:2:i_choiceDown(g)-1);
            game(g).rts       = sub(sn).rt(i_choiceDown(g)-10:2:i_choiceDown(g)-2);
        end
        if isempty(game(g).card)
            game(g).emotion = 'x';
        else
            game(g).emotion   = game(g).card(end-2);
        end
        
        if social
            [game(g).face_age, game(g).face_gender, game(g).face_trust] = add_face_columns(game(g).card);
        end
        
    end
    
    
    
    sub(sn).game = game;
    sub(sn).trials = length(game);
    game = game(1); % this is a hack
    
end