import { Explanation } from '../../modules/open-ai/explanation';
import { createVocabularyPage, createVocabularyPageSource, getDatabaseTitles } from '../../modules/notion/page';

const explanation = new Explanation(
    'sample',
    { name: '🥇よく使う', reason: 'サンプル' },
    { name: '🥉少し知的', reason: 'hoge' },
    { content: 'sample', supplement: 'サンプル' },
    'サンプル',
    'sample',
    [{ sentence: 'sample', japanese: 'サンプル' }],
    [{ sentence: 'sample', japanese: 'サンプル' }],
    [{ sentence: 'sample', japanese: 'サンプル' }],
    ['Noun', 'Verb'],
);

describe('Page', () => {
    // it('success has image', async () => {
    //     const expiration = new Explanation(
    //         'sample',
    //         { name: '🥇よく使う', reason: 'サンプル' },
    //         { name: '🥉少し知的', reason: 'hoge' },
    //         { content: 'sample', supplement: 'サンプル' },
    //         'サンプル',
    //         'sample',
    //         [{ sentence: 'sample', japanese: 'サンプル' }],
    //         [{ sentence: 'sample', japanese: 'サンプル' }],
    //         [{ sentence: 'sample', japanese: 'サンプル' }],
    //         'https://oaidalleapiprodscus.blob.core.windows.net/private/org-jHhdkCH43sdspVnIqTfy1RoH/user-fs6N78cHbaq5ODMzBujvTWyC/img-3PXAySfhRYHWOz3Hk5WueE9w.png?st=2024-05-19T07%3A22%3A02Z&se=2024-05-19T09%3A22%3A02Z&sp=r&sv=2021-08-06&sr=b&rscd=inline&rsct=image/png&skoid=6aaadede-4fb3-4698-a8f6-684d7786b067&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2024-05-19T05%3A34%3A37Z&ske=2024-05-20T05%3A34%3A37Z&sks=b&skv=2021-08-06&sig=VfJOj6vtufpfrz%2Bid1%2B6MtczdLik3sQWoRT7TBNuEU4%3D',
    //     );

    //     await createVocabularyPage(expiration);
    // });

    describe('createVocabularyPageSource', () => {
        it('returns success', async () => {
            const actual = createVocabularyPageSource(explanation);

            console.log(JSON.stringify(actual, null, 2));
        });
    });
});
