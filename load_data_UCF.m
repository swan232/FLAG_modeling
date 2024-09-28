function sub = load_data_UCF(datadir, varargin)
% hdr stands for header

hdr = {
    'rt'
    'stimulus'
    'key_press'
    'block'
    'type'
    'counter'
    'trial_index'
    'time_elapsed'
    'reward'
    'mean'
    'sigma'
    'side'
    'card'
    'choseDeck'
    'offer'
    'reward_on_choice'
    'age'
    'gender'
    }';

if nargin > 1
    demo = varargin{1}; % if one optional argument is provided, it is demo, which indicates whether demo data (age and gender) is provided
else
    demo = true;
end

% if two optional arguments are provided, the second optional arg specifies
% whether it is social FLAG 
if nargin > 2
    social = varargin{2};
else
    social = false;
end

% if demo is false, remove age and gender from list of fields to select 
if ~demo
    hdr = hdr(1:end-2);
end

clear sub
d = dir([datadir  '/' '*.csv']);

%length(d) is the number of files in folder, but not all are valid

sn_count = 0;

% read files in the folder into a structure
for sn = 1:length(d)
    % disp(sn)
    data = readtable([datadir '/' d(sn).name]);

    % prescreening 1316 rows
    if height(data) < 1316
        continue
    end
    
    f = @(x) any(x == string(data.Properties.VariableNames));
    % deal out (distribute) into a structure
    % dum = [];
    if all(cell2mat(cellfun(f, ["rt","stimulus","block","mean", "reward_on_choice"], 'UniformOutput',false)))

        % update the number of subjects 
        sn_count = sn_count + 1;

        % disp([string(sn) + ' : good file'])
        dum.filename = d(sn).name;
        % rename filenames in avatar data
        if (contains(d(sn).name, 'undefined'))
            dum.filename =  strrep(d(sn).name, 'undefined_', '');
        end
        
        for i = 1:length(hdr)
            dum =  setfield(dum, hdr{i}, getfield(data, hdr{i}));
            % dum.hdr{i} = data.hdr{i};
            
        end

        % gender1 as dummy variable (can't be logical)
        if demo
            % recode gender1: male 1, female 0
            if dum.gender == 1
                dum.gender1 = 1;
            else 
                dum.gender1 = 0;
            end
        end
             
        sub(sn_count) = dum;
        
    else
        disp(string(sn) + ' ' + d(sn).name + ' : bad file')
        continue
    end

end

