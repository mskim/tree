book_plan_csv=<<EOF
part,document,sub-document,template,page
front,cover,,cover,2
,preface,,preface,1
,forward,,forward,1
,toc,,toc,2
body,01-chapter,,chapter,10
,02-chapter,,chapter,10
,,photo-1,photo,4
,03-chapter,,chapter,10
,04-chapter,,chapter,10
,05-chapter,,chapter,10
,06-chapter,,chapter,10
,07-chapter,,chapter,10
,06-chapter,,chapter,10
,09-chapter,,chapter,10
,10-chapter,,chapter,10
rear,index,,index,2
EOF

Book.where(title: "Pastor And Texi Driver", kind: 'paperback', book_plan: book_plan_csv).first_or_create