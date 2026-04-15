import { translateExplanation } from '../../modules/open-ai/explanation';

const media = {
    vocabulary: 'book',
    type_of_vocabulary: '1',
    frequency_of_use_by_native_speakers: {
        level: 9,
        reason: '本を読むことや予約することは日常的な行動であり、頻繁に使われる。',
    },
    intellectual_level: {
        level: 5,
        reason: '一般的な単語であり、特に知的度を示すわけではないが、文脈によって知的に見えることがある。',
    },
    meanings: ['本', '予約する'],
    supplement: '『book』は読書に関連する場合と、何かを予約する場合の両方で使われる。',
    etymology: "古英語の 'bōc' に由来し、ドイツ語の 'Buch' やオランダ語の 'boek' と同じ起源を持つ。",
    pronunciation_symbol: 'bʊk',
    collocation: [
        {
            sentence: 'book + a room',
            japanese: '部屋を予約する',
        },
        {
            sentence: 'book + a ticket',
            japanese: 'チケットを予約する',
        },
        {
            sentence: 'read + a book',
            japanese: '本を読む',
        },
    ],
    example_sentences: [
        {
            english: 'I want to **book** a table for two.',
            japanese: '二人分のテーブルを**予約**したいです。',
        },
        {
            english: 'She loves reading a good **book** before bed.',
            japanese: '彼女は寝る前に良い**本**を読むのが好きです。',
        },
    ],
    similar_expressions: [
        {
            english: 'reserve',
            japanese: '予約する',
            point: "'book'と同じように使えるが、ややフォーマルな印象を与える。",
        },
        {
            english: 'schedule',
            japanese: '予定を入れる',
            point: '具体的な日時が決まっている場合に使われることが多い。',
        },
        {
            english: 'novel',
            japanese: '小説',
            point: '『book』の中でも特にフィクションの物語を指す場合に使う。',
        },
    ],
};

const rawMedia = JSON.stringify(media);

describe('Explanation', () => {
    describe('translateExplanation', () => {
        it('success', () => {
            const explanation = translateExplanation(rawMedia);

            console.log(explanation);
        });
    });
});
