CONFIG = fopen("../test/stimulus/config.csv","w");

for i=1:2
    cfg.operator = 0;
    cfg.sub_field_op = 1;
    cfg.src_dim = randi([10,100],1,1);
    cfg.dstn_dim = randi([10,100],1,1);
    cfg.src_addr = randi([200,1000],1,1);
    cfg.dstn_addr = randi([200,1000],1,1);
    cfg.in_size = randi([1,7],1,1);
    cfg.out_size = randi([1,7],1,1);

    fn = fieldnames(cfg);
    for i = 1:length(fn)
        fprintf(CONFIG,"%d,",cfg.(fn{i}));
    end
    fprintf(CONFIG,"\n");
end