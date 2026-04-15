import { Explanation, translateExplanation } from './explanation';

const createPrompt = (vocabulary: string) => {
    return `${vocabulary}について下記を教えてください。回答はJSON文字列で返してください。(■の後はkey名です)
  ■vocabulary: ${vocabulary}
  ■type_of_vocabulary:
  [数字文字列で回答,名詞は1,代名詞2,動詞は3,形容詞は4,副詞は5,助動詞は6,前置詞は7,冠詞は8,接続詞は9,その他は10]
  [複数の種類を持つ語彙は,区切りで回答,例(clearは形容詞と動詞なので "3,4")]
  ■frequency_of_use_by_native_speakers:
  [回答,key名はlevel,頻度を1~10(heads-upを8とした基準)で表すとして次の４つから選択{あまり使わない(頻度1~2),そこそこ使う(頻度3~5),よく使う(頻度6~8),非常によく使う(頻度9~10)},回答はレベルの数値]
  [回答,key名はreason,頻度の理由があれば日本語で回答,今回の語彙を文中で使う場合は'今回の語彙'のようにシングルクォーテーションで囲う]
  ■intellectual_level:
  [回答,key名はlevel,知的度を1~10(heads-upを8とした基準)で表すとして次の４つから選択{あまり知的ではない(頻度1~2),少し知的(頻度3~5),そこそこ知的(頻度6~8),かなり知的(頻度9~10)},回答はレベルの数値]
  [回答,key名はreason,知的度の理由があれば日本語で回答]
  ■meanings:
  [回答(簡潔に意味だけ記載: (例) breathtakingなら、息をのむような,驚くべき,すばらしい),配列で回答]
  [回答,key名はsupplement,ネイティブが使用する会話のシチュエーションや補足説明を日本語で回答,例: supplement: "過去の時点で何かを継続的に行っており、その時点まで続いていたことを強調する場合に使う。"]
  ■etymology:
  [日本語で回答]
  ■pronunciation_symbol:
  [回答]
  ■ collocation(今回の語彙+よく一緒に使用される語彙で記載: (例)今回教えてほしいのがadrenaline-fueledなら、adrenaline-fueled(今回の語彙) + adventure(よく一緒に使用される語彙)やadrenaline-fueled(今回の語彙) + sports(よく一緒に使用される語彙)など):
  [回答,配列で回答,例文のkey名はsentence,日本語訳のkey名はjapanese]
  [回答例:"collocation":[{"sentence":"collocation1","japanese":"collocation1 in japanese"},{"sentence":"collocation2","japanese":"collocation2 in japanese"},...]]
  ■example_sentences:
  [回答(ネイティブが会話で一番使いそうな例文を複数回答,配列で回答,英文のkey名はenglish,日本語訳のkey名はjapanese,英語の日本語文を記載, 該当箇所は太字で強調)]
  ■similar_expressions(類似表現とその擬似表現を会話で使用する上でのポイントを複数回答,擬似表現のポイントはできるだけ詳しく日本語で回答)]
  [回答,擬似表現は配列で回答,英語のkey名はenglish,日本語訳のkey名はjapanese,擬似表現を会話で使用する上でのポイントの説明のkey名はpoint]`;
};

type RawMedia = {
    id: string;
    object: string;
    created: number;
    model: string;
    usage: {
        prompt_tokens: number;
        completion_tokens: number;
        total_tokens: number;
    };
    choices: {
        message: {
            role: string;
            content: string;
        };
        logprobs: null;
        finish_reason: string;
        index: number;
    }[];
};

export type RawEntryMedia = {
    vocabulary: string;
    frequency_of_use_by_native_speakers: { level: number; reason: string };
    intellectual_level: { level: number; reason: string };
    meanings: string[];
    supplement: string;
    etymology: string;
    pronunciation_symbol: string;
    collocation: { sentence: string; japanese: string }[];
    example_sentences: { english: string; japanese: string }[];
    similar_expressions: { english: string; japanese: string; point: string }[];
    type_of_vocabulary: string;
};

export const getExpiration = async (vocabulary: string, imageUrl?: string): Promise<Explanation> => {
    try {
        const uri = process.env.OPENAI_API_ENDPOINT;

        if (!uri) {
            throw new Error('Open AI API endpoint is not defined');
        }

        const headers = {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
        };

        const prompt = createPrompt(vocabulary);

        const messages = [
            { role: 'system', content: 'あなたは英語のスペシャリストです。' },
            { role: 'user', content: prompt },
        ];

        const data = {
            max_tokens: 1000,
            model: 'gpt-4o',
            temperature: 0.7,
            messages,
        };

        const response = await fetch(uri, {
            method: 'POST',
            headers,
            body: JSON.stringify(data),
        });

        const rawMedia = (await response.json()) as RawMedia;

        const content = rawMedia.choices[0].message.content.replace('```json\n', '').replace('\n```', '');

        console.log('------ Open AI Explanation Response ------');
        console.log(content);
        console.log('------------------------------------------');

        return translateExplanation(JSON.parse(content), imageUrl);
    } catch (error) {
        console.log(error);
        throw new Error('Failed to get expiration');
    }
};
